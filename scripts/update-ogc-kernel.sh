#!/usr/bin/env bash
# Bump the OpenGamingCollective kernel pin in modules/ogc-kernel.nix (citadel only).
#
# The pin is vanilla <base> tarball + OGC's monolithic.patch. A bump is: new
# ogcRelease, new ogcModDir, and two new pure-content hashes (base tarball +
# patch). Used manually and by .github/workflows/check-ogc-update.yml.
#
#   ./scripts/update-ogc-kernel.sh --check              # exit 0 ok, 2 update available, 1 error
#   ./scripts/update-ogc-kernel.sh --apply [tag]        # rewrite the pin (defaults to latest tag)
set -euo pipefail

REPO="OpenGamingCollective/linux"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KERNEL_FILE="$ROOT/modules/ogc-kernel.nix"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"

die() {
  echo "error: $*" >&2
  exit 1
}

current_release() {
  sed -n 's/^  ogcRelease = "\(.*\)";$/\1/p' "$KERNEL_FILE"
}

latest_release() {
  curl -fsSL "$API_URL" | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])'
}

# OGC tags are v<kernel-base>-ogc<N>, e.g. v7.2-ogc4, v7.1.8-ogc1.
base_of() {
  local tag="$1"
  [[ "$tag" =~ ^v([0-9.]+)-ogc[0-9]+$ ]] || die "unexpected OGC tag format: $tag"
  echo "${BASH_REMATCH[1]}"
}

# modDirVersion must match the base tree's Makefile exactly. The base is the full
# kernel version (7.2 or 7.1.8); pad it to 3 components (7.2 -> 7.2.0).
mod_dir_version_of() {
  local base="$1" parts
  IFS='.' read -ra parts <<<"$base"
  while ((${#parts[@]} < 3)); do parts+=("0"); done
  echo "${parts[0]}.${parts[1]}.${parts[2]}"
}

base_tarball_url() {
  local base="$1"
  echo "https://cdn.kernel.org/pub/linux/kernel/v${base%%.*}.x/linux-${base}.tar.xz"
}

patch_url() {
  local tag="$1"
  echo "https://github.com/${REPO}/releases/download/${tag}/monolithic.patch"
}

# nix-prefetch-url without --unpack gives the pure file hash (version-independent,
# unlike fetchzip's unpacked-tree hash which differs across nix versions).
fetch_hash() {
  nix-prefetch-url "$1"
}

sri() {
  nix hash convert --hash-algo sha256 --to sri "$1"
}

rewrite_pin() {
  local tag="$1" mod_dir_version="$2" base_hash="$3" patch_hash="$4"
  python3 - "$KERNEL_FILE" "$tag" "$mod_dir_version" "$base_hash" "$patch_hash" <<'EOF'
import re, sys
path, tag, mod_dir_version, base_hash, patch_hash = sys.argv[1:6]
src = open(path).read()
src = re.sub(r'ogcRelease = "[^"]*";', f'ogcRelease = "{tag}";', src)
src = re.sub(r'ogcModDir = "[^"]*";', f'ogcModDir = "{mod_dir_version}";', src)
src = re.sub(r'ogcBaseHash = "[^"]*";', f'ogcBaseHash = "{base_hash}";', src)
src = re.sub(r'ogcPatchHash = "[^"]*";', f'ogcPatchHash = "{patch_hash}";', src)
open(path, "w").write(src)
EOF
}

check() {
  local current latest
  current="$(current_release)"
  latest="$(latest_release)"
  if [[ "$latest" == "$current" ]]; then
    echo "up to date (${current})"
    return 0
  fi
  echo "update available: ${current} -> ${latest}"
  return 2
}

apply() {
  local tag="${1:-$(latest_release)}"
  local current base mod_dir_version base_hash patch_hash
  current="$(current_release)"
  [[ "$tag" != "$current" ]] || die "already at ${tag}"
  echo "updating ${current} -> ${tag}"
  base="$(base_of "$tag")"
  mod_dir_version="$(mod_dir_version_of "$base")"
  echo "fetching base tarball hash ($(base_tarball_url "$base"))..."
  base_hash="$(sri "$(fetch_hash "$(base_tarball_url "$base")")")"
  echo "fetching patch hash ($(patch_url "$tag"))..."
  patch_hash="$(sri "$(fetch_hash "$(patch_url "$tag")")")"
  rewrite_pin "$tag" "$mod_dir_version" "$base_hash" "$patch_hash"
  echo "done: ${KERNEL_FILE} now pins ${tag} (base ${base}, modDirVersion ${mod_dir_version})"
}

case "${1:-}" in
  --check) check ;;
  --apply) apply "${2:-}" ;;
  *) die "usage: $0 --check | --apply [tag]" ;;
esac