#!/usr/bin/env bash
# Bump the OpenGamingCollective kernel pin in modules/ogc-kernel.nix.
#
# The OGC release tag IS the kernel (vanilla tree + their patches applied), so a
# bump is just: new archive hash + new ogcRelease + new modDirVersion (derived
# from the tag's kernel base). Used manually and by .github/workflows/check-ogc-update.yml.
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

archive_url() {
  echo "https://github.com/${REPO}/archive/refs/tags/$1.tar.gz"
}

# fetchzip hashes the unpacked, root-stripped tree; nix-prefetch-url --unpack
# computes exactly that and stores the tree in the nix store.
fetchzip_hash() {
  nix-prefetch-url --unpack "$(archive_url "$1")"
}

# OGC tags are v<kernel-base>-ogc<N>, e.g. v7.2-ogc4, v7.1.8-ogc1.
base_of() {
  local tag="$1"
  [[ "$tag" =~ ^v([0-9.]+)-ogc[0-9]+$ ]] || die "unexpected OGC tag format: $tag"
  echo "${BASH_REMATCH[1]}"
}

# modDirVersion must match the tree's Makefile exactly. The base is the full
# kernel version (7.2 or 7.1.8); pad it to 3 components (7.2 -> 7.2.0).
mod_dir_version_of() {
  local base="$1" parts
  IFS='.' read -ra parts <<<"$base"
  while ((${#parts[@]} < 3)); do parts+=("0"); done
  echo "${parts[0]}.${parts[1]}.${parts[2]}"
}

rewrite_pin() {
  local tag="$1" sri="$2" mod_dir_version="$3"
  python3 - "$KERNEL_FILE" "$tag" "$sri" "$mod_dir_version" <<'EOF'
import re, sys
path, tag, sri, mod_dir_version = sys.argv[1:5]
src = open(path).read()
src = re.sub(r'ogcRelease = "[^"]*";', f'ogcRelease = "{tag}";', src)
src = re.sub(r'(url = "https://github.com/OpenGamingCollective/linux/archive[^\n]*\n\s*)hash = "[^"]*";',
             rf'\1hash = "{sri}";', src)
src = re.sub(r'modDirVersion = "[^"]*";', f'modDirVersion = "{mod_dir_version}";', src)
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
  local current hash sri mod_dir_version
  current="$(current_release)"
  [[ "$tag" != "$current" ]] || die "already at ${tag}"
  echo "updating ${current} -> ${tag}"
  mod_dir_version="$(mod_dir_version_of "$(base_of "$tag")")"
  hash="$(fetchzip_hash "$tag")"
  sri="$(nix hash convert --hash-algo sha256 --to sri "$hash")"
  rewrite_pin "$tag" "$sri" "$mod_dir_version"
  echo "done: ${KERNEL_FILE} now pins ${tag} (modDirVersion ${mod_dir_version}, hash ${sri})"
}

case "${1:-}" in
  --check) check ;;
  --apply) apply "${2:-}" ;;
  *) die "usage: $0 --check | --apply [tag]" ;;
esac