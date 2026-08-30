#!/usr/bin/env bash
# Bump all the pinned upstream dependencies in one shot:
#
#   ge       GE-Proton      modules/proton-ge.nix
#   cachyos  Proton-CachyOS modules/proton-cachyos.nix
#   ogc      OpenGamingCollective kernel modules/ogc-kernel.nix
#   flake    nix flake lock  flake.lock
#
# Used manually and by .github/workflows/check-updates.yml (single pipeline
# that opens one PR with every bump).
#
# Exit codes: 0 = success (nothing to do / applied), 1 = error. Results are
# communicated on stdout: check prints "pending:<tools>", apply prints the
# markdown summary (empty when nothing applied).
#
#   ./scripts/update.sh check                    # aggregate: prints pending, exit 0
#   ./scripts/update.sh apply                    # aggregate: prints summary, exit 0
#   ./scripts/update.sh <tool> --check
#   ./scripts/update.sh <tool> --apply [tag]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# flake first: the OGC base guard evaluates the kernel version from the
# flake.lock, so it must be updated before ogc is checked/applied.
TOOLS=(flake ge cachyos ogc)
# Tools with pending updates, printed on stdout so the workflow can use them
# in the PR body. Human messages go to stderr.
PENDING=""
APPLIED=""
# Markdown lines (one per applied tool) for the PR body, printed on stdout by
# apply_all.
SUMMARY_LINES=()

die() {
  echo "error: $*" >&2
  exit 1
}

tool_file() {
  case "$1" in
    ge) echo "$ROOT/modules/proton-ge.nix" ;;
    cachyos) echo "$ROOT/modules/proton-cachyos.nix" ;;
    ogc) echo "$ROOT/modules/ogc-kernel.nix" ;;
    flake) echo "$ROOT/flake.lock" ;;
    *) die "unknown tool: $1 (expected ${TOOLS[*]})" ;;
  esac
}

tool_repo() {
  case "$1" in
    ge) echo "GloriousEggroll/proton-ge-custom" ;;
    cachyos) echo "CachyOS/proton-cachyos" ;;
    ogc) echo "OpenGamingCollective/linux" ;;
    flake) die "flake has no upstream repo" ;;
    *) die "unknown tool: $1" ;;
  esac
}

tool_label() {
  case "$1" in
    ge) echo "GE-Proton" ;;
    cachyos) echo "Proton-CachyOS" ;;
    ogc) echo "OGC kernel" ;;
    flake) echo "flake.lock" ;;
  esac
}

current_release() {
  case "$1" in
    ge) sed -n 's/^[[:space:]]*release = "\(.*\)";$/\1/p' "$(tool_file "$1")" ;;
    cachyos) sed -n 's/^[[:space:]]*release = "\(.*\)";$/\1/p' "$(tool_file "$1")" ;;
    ogc) sed -n 's/^  ogcRelease = "\(.*\)";$/\1/p' "$(tool_file "$1")" ;;
    flake) die "flake.lock has no pinned release" ;;
  esac
}

# Resolve the web redirect instead of hitting api.github.com — unauthenticated
# API calls get rate-limited (HTTP 403) on CI runners, which previously made
# the proton pipeline collapse into garbage URLs ("" <tag> "").
latest_tag() {
  local redir
  redir="$(curl -fsS --http1.1 -o /dev/null -w '%{redirect_url}' \
    "https://github.com/$(tool_repo "$1")/releases/latest")" || die "could not resolve latest release"
  local tag="${redir##*/}"
  [[ "$redir" == */releases/tag/* && -n "$tag" ]] || die "unexpected latest-release redirect: $redir"
  echo "$tag"
}

# The version stored in the modules is the upstream tag without CachyOS's
# "cachyos-" prefix (only part of the release tag, not of the asset name).
version_of_tag() {
  local tool="$1" tag="$2"
  case "$tool" in
    ge) echo "$tag" ;;
    cachyos) [[ "$tag" == cachyos-* ]] && echo "${tag#cachyos-}" || die "unexpected cachyos tag: $tag" ;;
    ogc) echo "$tag" ;;
    flake) die "flake has no tags" ;;
  esac
}

asset_url() {
  local tool="$1" version="$2" tag="$3"
  case "$tool" in
    ge) echo "https://github.com/$(tool_repo "$tool")/releases/download/${tag}/${tag}-x86_64.tar.gz" ;;
    cachyos) echo "https://github.com/$(tool_repo "$tool")/releases/download/${tag}/proton-cachyos-${version}-x86_64.tar.xz" ;;
    ogc) echo "https://github.com/$(tool_repo "$tool")/releases/download/${tag}/monolithic.patch" ;;
    flake) die "flake has no assets" ;;
  esac
}

# Pure file hash (fetchurl), version-independent across nix versions.
sri() {
  nix hash convert --hash-algo sha256 --to sri "$1"
}

# OGC tags are v<kernel-base>-ogc<N>, e.g. v7.2-ogc4, v7.2.1-ogc2.
base_of() {
  local tag="$1"
  [[ "$tag" =~ ^v([0-9.]+)-ogc[0-9]+$ ]] || die "unexpected OGC tag format: $tag"
  echo "${BASH_REMATCH[1]}"
}

# Normalize a version to three dot-separated components (7.2 -> 7.2.0) so
# 7.2 == 7.2.0 but 7.2 != 7.2.1.
normalize_version() {
  local v="$1" out="" i
  IFS='.' read -r -a parts <<< "$v"
  for i in 0 1 2; do
    out="${out}${out:+.}${parts[$i]:-0}"
  done
  echo "$out"
}

# The kernel version the OGC patch is applied onto (nixpkgs's linux_latest).
# The override doesn't change `version`, so this is not circular.
kernel_version() {
  nix eval --raw "$ROOT#nixosConfigurations.citadel.config.boot.kernelPackages.kernel.version" 2>/dev/null
}

# True (exit 0) when the OGC tag's base differs from the kernel nixpkgs
# provides. The patch may not apply then, so the bump is skipped — it is
# applied automatically on a later cron once nixpkgs catches up to the base.
ogc_base_mismatch() {
  local tag="$1" base nixver
  base="$(base_of "$tag")"
  nixver="$(kernel_version)" || {
    echo "warning: could not evaluate citadel kernel version; skipping OGC bump" >&2
    return 0
  }
  if [[ "$(normalize_version "$base")" != "$(normalize_version "$nixver")" ]]; then
    echo "warning: OGC ${tag} targets kernel ${base} but nixpkgs linux_latest is ${nixver} — skipping (will bump once nixpkgs reaches ${base})" >&2
    return 0
  fi
  return 1
}

rewrite_pin() {
  local tool="$1" release="$2" hash="$3" file
  file="$(tool_file "$tool")"
  python3 - "$tool" "$file" "$release" "$hash" <<'EOF'
import re, sys
tool, path, release, hash = sys.argv[1:5]
src = open(path).read()
if tool == "ogc":
    src = re.sub(r'ogcRelease = "[^"]*";', f'ogcRelease = "{release}";', src)
    src = re.sub(r'hash = "sha256-[^"]*";', f'hash = "{hash}";', src)
else:
    src = re.sub(r'release = "[^"]*";', f'release = "{release}";', src)
    src = re.sub(r'hash = "sha256-[^"]*";', f'hash = "{hash}";', src)
open(path, "w").write(src)
EOF
}

check_tool() {
  local tool="$1" current latest
  current="$(current_release "$tool")"
  latest="$(latest_tag "$tool")"
  if [[ "$(version_of_tag "$tool" "$latest")" == "$current" ]]; then
    echo "$(tool_label "$tool") up to date (${current})" >&2
    return 0
  fi
  # OGC: only bump when the tag's base matches the kernel nixpkgs provides.
  if [[ "$tool" == ogc ]] && ogc_base_mismatch "$latest"; then
    return 0
  fi
  echo "$(tool_label "$tool") update available: ${current} -> $(version_of_tag "$tool" "$latest")" >&2
  PENDING="$PENDING $tool"
}

check_flake() {
  local keep="${1:-}"
  echo "checking flake.lock..." >&2
  # `nix flake update` is the only reliable way to know; it mutates the lock.
  # With --keep the change is left in place so later checks (ogc's base guard)
  # see the newer nixpkgs; check_all reverts it at the end.
  nix flake update --flake "$ROOT" >&2
  if git -C "$ROOT" diff --quiet -- flake.lock; then
    echo "flake.lock up to date" >&2
    [[ "$keep" == --keep ]] || git -C "$ROOT" checkout -- flake.lock
    return 0
  fi
  echo "flake.lock update available" >&2
  PENDING="$PENDING flake"
  [[ "$keep" == --keep ]] || git -C "$ROOT" checkout -- flake.lock
}

apply_tool() {
  local tool="$1" tag="${2:-$(latest_tag "$1")}" current release hash
  [[ -n "$tag" ]] || die "empty tag; won't build a download URL from it"
  current="$(current_release "$tool")"
  release="$(version_of_tag "$tool" "$tag")"
  [[ "$release" != "$current" ]] || { echo "$(tool_label "$tool") already at ${release}" >&2; return 0; }

  # OGC: only bump when the tag's base matches the kernel nixpkgs provides.
  if [[ "$tool" == ogc ]] && ogc_base_mismatch "$tag"; then
    return 0
  fi

  echo "updating $(tool_label "$tool") ${current} -> ${release}" >&2
  echo "fetching hash ($(asset_url "$tool" "$release" "$tag"))..." >&2
  hash="$(sri "$(nix-prefetch-url "$(asset_url "$tool" "$release" "$tag")")")"
  rewrite_pin "$tool" "$release" "$hash"
  echo "$(tool_label "$tool") pinned to ${release}" >&2
  APPLIED="$APPLIED $tool"

  SUMMARY_LINES+=("- **$(tool_label "$tool")**: \`${current}\` → \`${release}\`")
}

apply_flake() {
  echo "updating flake.lock..." >&2
  nix flake update --flake "$ROOT" >&2
  if git -C "$ROOT" diff --quiet -- flake.lock; then
    echo "flake.lock up to date" >&2
    return 0
  fi
  echo "flake.lock updated" >&2
  APPLIED="$APPLIED flake"
  SUMMARY_LINES+=("- **flake.lock**: updated via \`nix flake update\`")
}

# Aggregate check: prints "pending:<tools>" on stdout (empty when nothing is
# pending) and exits 0. Errors abort.
check_all() {
  for tool in "${TOOLS[@]}"; do
    if [[ "$tool" == flake ]]; then
      # Keep the lock update so ogc's base guard sees the newer nixpkgs;
      # revert it after all checks.
      check_flake --keep
    else
      check_tool "$tool"
    fi
  done
  git -C "$ROOT" checkout -- flake.lock 2>/dev/null || true
  echo "pending:${PENDING}"
}

# Aggregate apply: exits 0 whether or not anything was applied. Errors abort.
# The markdown summary (PR body) goes to stdout; human messages to stderr.
apply_all() {
  for tool in "${TOOLS[@]}"; do
    if [[ "$tool" == flake ]]; then
      apply_flake
    else
      apply_tool "$tool"
    fi
  done
  echo "applied:${APPLIED}" >&2
  for line in "${SUMMARY_LINES[@]}"; do
    echo "$line"
  done
}

usage() {
  die "usage: $0 check | apply | <ge|cachyos|ogc|flake> --check | --apply [tag]"
}

case "${1:-}" in
  check) check_all ;;
  apply) apply_all ;;
  ge|cachyos|ogc|flake)
    tool="$1"
    shift
    case "${1:-}" in
      --check)
        if [[ "$tool" == flake ]]; then
          check_flake
        else
          check_tool "$tool"
        fi
        ;;
      --apply)
        if [[ "$tool" == flake ]]; then
          apply_flake
        else
          apply_tool "$tool" "${2:-}"
        fi
        ;;
      *) usage ;;
    esac
    ;;
  *) usage ;;
esac