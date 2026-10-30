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
# The Steam client and its games (~/.steam + ~/.local/share/Steam) are ALWAYS
# kept: they are big downloaded data, not desktop state, so re-downloading them
# on every wipe would be painful. (On citadel the library lives on /GAMES, a
# separate filesystem outside $HOME, so it is safe either way.)
#
#   ./scripts/reset-home.sh                     # interactive confirmation (needs a tty)
#   ./scripts/reset-home.sh --yes               # skip confirmation
#   ./scripts/reset-home.sh --dry-run           # only print what would be deleted
#   ./scripts/reset-home.sh --keep .ssh         # also keep ~/.ssh (repeatable; paths
#                                               # are relative to $HOME or absolute,
#                                               # and may be nested, e.g.
#                                               # .local/share/Steam)
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
# Always kept: the repo (so the flake survives) and the Steam client + games
# (big downloaded data, not desktop state — kept so a wipe never forces a
# re-download). Paths may be nested; see collect() below.
KEEPS=("$REPO" "$HOME/.steam" "$HOME/.local/share/Steam")

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes) YES=1 ;;
    --dry-run) DRY_RUN=1 ;;
    --ignore-mounts) IGNORE_MOUNTS=1 ;;
    --keep)
      [[ $# -ge 2 ]] || die "--keep needs a path (relative to \$HOME, or absolute)"
      v="${2%/}" # drop a trailing slash so matching stays exact
      if [[ "$v" == /* ]]; then
        KEEPS+=("$v")
      else
        KEEPS+=("$HOME/$v")
      fi
      shift
      ;;
    *) die "unknown argument: $1 (see header for usage)" ;;
  esac
  shift
done

[[ "$YES" -eq 1 || -t 0 ]] || die "stdin is not a terminal and --yes was not given"

# Everything at the top of $HOME, including dotfiles (dotglob), minus keeps.
# Keeps may be nested, so walk the tree: skip a keep, recurse into an ancestor
# of a keep (deleting the ancestor's other children), delete everything else.
is_keep() {
  local p="$1" k
  for k in "${KEEPS[@]}"; do
    [[ "$p" == "$k" ]] && return 0
  done
  return 1
}

is_ancestor_of_keep() {
  local p="$1" k
  for k in "${KEEPS[@]}"; do
    [[ "$k" == "$p"/* ]] && return 0
  done
  return 1
}

to_delete=()
collect() {
  local dir="$1" entry
  shopt -s dotglob nullglob
  for entry in "$dir"/*; do
    if is_keep "$entry"; then
      continue
    elif is_ancestor_of_keep "$entry"; then
      collect "$entry"
    else
      to_delete+=("$entry")
    fi
  done
  shopt -u dotglob nullglob
}
collect "$HOME"

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
