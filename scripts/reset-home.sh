#!/usr/bin/env bash
# Full-wipe reset of the current user's home directory — a clean slate for
# testing desktop migrations (GNOME ↔ KDE ↔ Hyprland) or anything else
# user-state-ish.
#
# Deletes EVERY file and directory under $HOME, including personal data
# (Documents, Downloads, ...), dotfiles, caches and secrets (~/.ssh, ~/.gnupg).
# The repo itself ($HOME/nixos-config) is always kept so the flake survives;
# re-run your rebuild afterwards to regenerate the declarative state (configs,
# packages, dconf/plasma defaults come back from home-manager).
#
#   ./scripts/reset-home.sh                     # interactive confirmation (needs a tty)
#   ./scripts/reset-home.sh --yes               # skip confirmation
#   ./scripts/reset-home.sh --dry-run           # only print what would be deleted
#   ./scripts/reset-home.sh --keep .ssh         # also keep ~/.ssh (repeatable; paths
#                                               # are relative to $HOME or absolute)
#   ./scripts/reset-home.sh --ignore-mounts    # proceed even if mount points found
#
# Safety rails (there on purpose — don't bypass casually):
#   - refuses to run as root
#   - refuses when $HOME is unset or '/'
#   - aborts if anything under $HOME is a mount point: `rm -rf` would descend
#     into the mounted filesystem and delete its contents; check what is
#     mounted first, then override with --ignore-mounts if you really mean it
#   - requires --yes or a typed confirmation (and refuses non-tty stdin)
set -euo pipefail

die() {
  echo "error: $*" >&2
  exit 1
}

[[ "$(id -u)" -ne 0 ]] || die "refusing to run as root (that would wipe /root, not a user home)"
[[ -n "${HOME:-}" && "$HOME" != "/" ]] || die "HOME is unset or '/' — refusing"
[[ -d "$HOME" ]] || die "HOME ($HOME) is not a directory — refusing"

REPO="$(cd "$(dirname "$0")/.." && pwd)" # always preserved

DRY_RUN=0
YES=0
IGNORE_MOUNTS=0
KEEPS=("$REPO")

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes) YES=1 ;;
    --dry-run) DRY_RUN=1 ;;
    --ignore-mounts) IGNORE_MOUNTS=1 ;;
    --keep)
      [[ $# -ge 2 ]] || die "--keep needs a path (relative to \$HOME, or absolute)"
      if [[ "$2" == /* ]]; then
        KEEPS+=("$2")
      else
        KEEPS+=("$HOME/$2")
      fi
      shift
      ;;
    *) die "unknown argument: $1 (see header for usage)" ;;
  esac
  shift
done

[[ "$YES" -eq 1 || -t 0 ]] || die "stdin is not a terminal and --yes was not given"

# Everything at the top of $HOME, including dotfiles (dotglob), minus keeps.
shopt -s dotglob nullglob
entries=("$HOME"/*)
shopt -u dotglob nullglob

to_delete=()
for entry in "${entries[@]}"; do
  keep=0
  for k in "${KEEPS[@]}"; do
    if [[ "$entry" == "$k" ]]; then
      keep=1
      break
    fi
  done
  [[ "$keep" -eq 1 ]] || to_delete+=("$entry")
done

if [[ ${#to_delete[@]} -eq 0 ]]; then
  echo "nothing to wipe under $HOME" >&2
  exit 0
fi

# Refuse to rm -rf a mount point: that deletes the mounted filesystem's contents.
if [[ "$IGNORE_MOUNTS" -eq 0 ]] && command -v mountpoint >/dev/null 2>&1; then
  mounts=()
  for entry in "${to_delete[@]}"; do
    if mountpoint -q "$entry"; then
      mounts+=("$entry")
    fi
  done
  if [[ ${#mounts[@]} -gt 0 ]]; then
    die "mount point(s) under \$HOME: ${mounts[*]} — check them first, then re-run with --ignore-mounts"
  fi
fi

echo "about to delete:" >&2
printf '  %s\n' "${to_delete[@]}" >&2
echo "keeping: ${KEEPS[*]}" >&2
echo "note: secrets (~/.ssh, ~/.gnupg) are deleted too — pass --keep .ssh (or similar) to keep them" >&2

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "dry run — nothing deleted" >&2
  exit 0
fi

if [[ "$YES" -ne 1 ]]; then
  read -r -p "type YES to wipe everything under $HOME: " resp
  [[ "$resp" == "YES" ]] || die "confirmation cancelled"
fi

cd /
rm -rf -- "${to_delete[@]}"

echo "done — $HOME is empty (except ${REPO})." >&2
host="$(cat /proc/sys/kernel/hostname 2>/dev/null || hostname 2>/dev/null || true)"
echo "rebuild to regenerate the declarative state:" >&2
if [[ -n "$host" ]]; then
  echo "  nixos-rebuild switch --flake ${REPO}#${host}" >&2
else
  echo "  nixos-rebuild switch --flake ${REPO}#<host>" >&2
fi
