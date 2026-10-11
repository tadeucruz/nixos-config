#!/usr/bin/env bash
#
# clean-gnome.sh — Remove leftover GNOME user config after switching to KDE.
#
# The system side is already clean: NixOS is declarative, so `nixos-rebuild
# switch` after swapping `modules/desktop/gnome.nix` -> `kde.nix` drops the
# GNOME packages/services. This script only cleans $HOME (dconf database,
# GNOME dotfiles/caches, orphan autostart entries).
#
# Usage:
#   ./scripts/clean-gnome.sh                 # list targets, ask before touching
#   ./scripts/clean-gnome.sh --dry-run       # only print, never touch anything
#   ./scripts/clean-gnome.sh --apply         # no prompt
#
# NOTE: also deletes ~/.local/share/keyrings (GNOME Keyring passwords are NOT
# recoverable; KDE uses KWallet in ~/.local/share/kwalletd instead), and resets
# dconf without any backup — this is a cleanup tool, not a migration one.
#
# Run it as your normal user (tadeucruz), after the rebuild, on the machine
# you migrated (e.g. prothean).

set -euo pipefail

APPLY=0
DRY=0

for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --dry-run) DRY=1 ;;
    -h|--help)
      sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "unknown flag: $arg (see --help)" >&2
      exit 1
      ;;
  esac
done

# GNOME-ish dotfiles/caches/autostart leftovers under $HOME. Globs are
# expanded only for existing paths; KDE/Qt/flatpak/gaming files are untouched
# (deliberately no broad `rm -rf ~/.config` or blanket autostart wipe —
# home/gaming.nix drops a Steam autostart entry that must survive).
gnome_paths() {
  local p
  for p in \
    "$HOME/.config/dconf" \
    "$HOME/.config/monitors.xml" \
    "$HOME/.config/gnome-terminalrc" \
    "$HOME"/.config/gnome-* \
    "$HOME"/.cache/gnome-* \
    "$HOME"/.local/share/gnome-* \
    "$HOME/.local/share/glib-2.0" \
    "$HOME/.cache/evolution" \
    "$HOME/.config/evolution" \
    "$HOME/.local/share/evolution" \
    "$HOME/.local/share/keyrings"
  do
    [ -e "$p" ] && printf '%s\n' "$p"
  done || true

  # Orphan autostart entries created by GNOME bits only (extensions, gsd,
  # evolution, tracker). Matched by name so other autostart entries stay.
  local f
  for f in "$HOME"/.config/autostart/*.desktop; do
    [ -e "$f" ] || continue
    case "$(basename "$f")" in
      *gnome*|*gsd-*|*evolution*|*tracker*|org.gnome.*)
        printf '%s\n' "$f"
        ;;
    esac
  done
}

TARGETS="$(gnome_paths | sort -u)"

if [ -z "$TARGETS" ]; then
  echo "No GNOME leftovers found in \$HOME. Nothing to do."
  exit 0
fi

echo "GNOME leftovers that will be removed:"
echo "$TARGETS" | sed 's/^/  /'
echo
echo "Also: dconf reset -f / (no backup — fresh start for the Plasma session)"

if [ "$DRY" = 1 ]; then
  echo
  echo "--dry-run: nothing was changed."
  exit 0
fi

if [ "$APPLY" != 1 ]; then
  echo
  read -r -p "Proceed? [y/N] " reply
  case "$reply" in
    y|Y|yes|YES) ;;
    *) echo "Aborted."; exit 1 ;;
  esac
fi

# Reset the dconf database first (no backup on purpose — cleanup, not migration).
if command -v dconf >/dev/null 2>&1; then
  dconf reset -f / || true
  echo "dconf database reset."
else
  echo "dconf not found; skipping database reset (removing ~/.config/dconf instead)."
fi

while IFS= read -r path; do
  [ -n "$path" ] || continue
  rm -rf -- "$path"
  echo "removed: $path"
done <<<"$TARGETS"

echo
echo "Done. Re-login (or reboot) so the Plasma session starts fully clean."