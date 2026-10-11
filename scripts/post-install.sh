#!/usr/bin/env bash
# Post-install bootstrap for a freshly installed NixOS machine.
#
# A fresh NixOS has no git, so this script re-execs itself inside a flakes
# shell to get it, clones the repo over HTTPS (fetch/pull), copies the
# machine's freshly generated hardware-configuration.nix into the chosen
# host directory, makes a baseline commit and points push at the Forgejo
# SSH endpoint (tailscale).
#
#   ./scripts/post-install.sh <host>     # e.g. citadel, prothean, legion, omega
#
# Pull/fetch: https://git.tadeucruz.com/tadeucruz/nixos-config.git (Cloudflare)
# Push:       ssh://forgejo@omega.tail0a0fce.ts.net:2222/tadeucruz/nixos-config.git
set -euo pipefail

CLONE_URL="https://git.tadeucruz.com/tadeucruz/nixos-config.git"
PUSH_URL="ssh://forgejo@omega.tail0a0fce.ts.net:2222/tadeucruz/nixos-config.git"
DEST="${HOME}/nixos-config"

die() {
  echo "error: $*" >&2
  exit 1
}

# Fresh NixOS has no git. Use the flake registry (no channel/NIX_PATH needed)
# so this works on a minimal install; enable flakes explicitly in case they
# are not on by default yet.
if ! command -v git >/dev/null 2>&1; then
  echo "git not found — fetching it via 'nix shell nixpkgs#git'..." >&2
  exec nix --extra-experimental-features "nix-command flakes" shell nixpkgs#git -c "$0" "$@"
fi

host="${1:-}"
[[ -n "$host" ]] || die "usage: $0 <host> (e.g. citadel, prothean, legion, omega)"

if [[ -e "$DEST" ]]; then
  [[ -d "$DEST" && -z "$(ls -A "$DEST")" ]] || die "$DEST already exists and is not empty"
fi

echo "cloning ${CLONE_URL} into ${DEST}..." >&2
git clone "$CLONE_URL" "$DEST"

[[ -f "$DEST/hosts/${host}/configuration.nix" ]] || die "unknown host '${host}' (no hosts/${host}/configuration.nix in the repo)"

echo "generating hardware-configuration.nix for '${host}'..." >&2
nixos-generate-config --show-hardware-config > "$DEST/hosts/${host}/hardware-configuration.nix"

git -C "$DEST" config user.name  >/dev/null 2>&1 || git -C "$DEST" config user.name tadeucruz
git -C "$DEST" config user.email >/dev/null 2>&1 || git -C "$DEST" config user.email tadeucruz@gmail.com

git -C "$DEST" add .
git -C "$DEST" commit -m "chore: bootstrap ${host} hardware-configuration.nix"

echo "setting push URL to the Forgejo SSH endpoint..." >&2
git -C "$DEST" remote set-url --push origin "$PUSH_URL"

echo "done. repo at ${DEST} (fetch: HTTPS, push: SSH)" >&2