#!/usr/bin/env bash
# Bump the pinned Proton releases in modules/proton-ge.nix and
# modules/proton-cachyos.nix (shared by citadel + prothean + legion).
#
# Both Protons move fast upstream; nixpkgs's proton-ge-bin lags and CachyOS is
# not in nixpkgs at all, so the pins live here. Used manually and by
# .github/workflows/check-proton-update.yml.
#
#   ./scripts/update-proton.sh ge --check              # exit 0 ok, 2 update available, 1 error
#   ./scripts/update-proton.sh ge --apply [tag]        # rewrite the pin (defaults to latest tag)
#   ./scripts/update-proton.sh cachyos --check
#   ./scripts/update-proton.sh cachyos --apply [tag]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

die() {
  echo "error: $*" >&2
  exit 1
}

tool_file() {
  case "$1" in
    ge) echo "$ROOT/modules/proton-ge.nix" ;;
    cachyos) echo "$ROOT/modules/proton-cachyos.nix" ;;
    *) die "unknown tool: $1 (expected ge|cachyos)" ;;
  esac
}

tool_repo() {
  case "$1" in
    ge) echo "GloriousEggroll/proton-ge-custom" ;;
    cachyos) echo "CachyOS/proton-cachyos" ;;
  esac
}

current_release() {
  sed -n 's/^[[:space:]]*release = "\(.*\)";$/\1/p' "$(tool_file "$1")"
}

latest_tag() {
  # Resolve the web redirect instead of hitting api.github.com — unauthenticated
  # API calls get rate-limited (HTTP 403) on CI runners, which previously made
  # the pipeline collapse into garbage URLs ("" <tag> "").
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
  esac
}

asset_url() {
  local tool="$1" version="$2" tag="$3"
  case "$tool" in
    ge) echo "https://github.com/$(tool_repo "$tool")/releases/download/${tag}/${tag}-x86_64.tar.gz" ;;
    cachyos) echo "https://github.com/$(tool_repo "$tool")/releases/download/${tag}/proton-cachyos-${version}-x86_64.tar.xz" ;;
  esac
}

# Pure file hash (fetchurl), version-independent across nix versions — the same
# lesson as update-ogc-kernel.sh.
sri() {
  nix hash convert --hash-algo sha256 --to sri "$1"
}

rewrite_pin() {
  local tool="$1" release="$2" hash="$3" file
  file="$(tool_file "$tool")"
  python3 - "$file" "$release" "$hash" <<'EOF'
import re, sys
path, release, hash = sys.argv[1:4]
src = open(path).read()
src = re.sub(r'release = "[^"]*";', f'release = "{release}";', src)
src = re.sub(r'hash = "sha256-[^"]*";', f'hash = "{hash}";', src)
open(path, "w").write(src)
EOF
}

check() {
  local tool="$1" current latest
  current="$(current_release "$tool")"
  latest="$(latest_tag "$tool")"
  if [[ "$(version_of_tag "$tool" "$latest")" == "$current" ]]; then
    echo "up to date (${current})"
    return 0
  fi
  echo "update available: ${current} -> $(version_of_tag "$tool" "$latest")"
  return 2
}

apply() {
  local tool="$1" tag="${2:-$(latest_tag "$1")}" current release hash
  [[ -n "$tag" ]] || die "empty tag; won't build a download URL from it"
  current="$(current_release "$tool")"
  release="$(version_of_tag "$tool" "$tag")"
  [[ "$release" != "$current" ]] || die "already at ${release}"
  echo "updating ${current} -> ${release}"
  echo "fetching hash ($(asset_url "$tool" "$release" "$tag"))..."
  hash="$(sri "$(nix-prefetch-url "$(asset_url "$tool" "$release" "$tag")")")"
  rewrite_pin "$tool" "$release" "$hash"
  echo "done: $(tool_file "$tool") now pins ${release}"
}

if [[ $# -lt 2 ]]; then
  die "usage: $0 <ge|cachyos> --check | --apply [tag]"
fi
tool="$1"
shift
case "${1:-}" in
  --check) check "$tool" ;;
  --apply) apply "$tool" "${2:-}" ;;
  *) die "usage: $0 <ge|cachyos> --check | --apply [tag]" ;;
esac