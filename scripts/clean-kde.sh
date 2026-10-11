#!/usr/bin/env bash
#
# clean-kde.sh — Remove leftover KDE/Qt user config after switching to GNOME.
#
# The system side is already clean: NixOS is declarative, so `nixos-rebuild
# switch` after swapping `modules/desktop/kde.nix` -> `gnome.nix` drops the
# KDE packages/services. This script only cleans $HOME (Plasma/KWin state,
# KDE Connect, konsole profiles, dolphin, KWallet, caches, orphan autostart).
#
# Usage:
#   ./scripts/clean-kde.sh                 # list targets, ask before touching
#   ./scripts/clean-kde.sh --dry-run       # only print, never touch anything
#   ./scripts/clean-kde.sh --apply         # no prompt
#
# NOTE: also deletes ~/.local/share/kwalletd — KWallet passwords are NOT
# recoverable (export them from KDE first if you still need them). Shared
# freedesktop files (mimeapps.list, ~/.cache/thumbnails, XDG portals) and
# the GNOME/flatpak/gaming files are deliberately untouched — home/gaming.nix
# drops a Steam autostart entry that must survive.
#
# Run it as your normal user (tadeucruz), logged OUT of the Plasma session
# (plasmashell/kwalletd must not be running — otherwise they recreate state
# while we delete), on the machine you migrated (e.g. prothean).

set -euo pipefail

APPLY=0
DRY=0

for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --dry-run) DRY=1 ;;
    -h|--help)
      sed -n '2,23p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "unknown flag: $arg (see --help)" >&2
      exit 1
      ;;
  esac
done

# KDE/Qt/Plasma dotfiles, caches and state under $HOME. Globs are expanded
# only for existing paths; GNOME/flatpak/gaming files are untouched
# (deliberately no broad `rm -rf ~/.config` or blanket autostart wipe —
# home/gaming.nix drops a Steam autostart entry that must survive).
# Deliberately NOT matched: ~/.config/keepassxc, ~/.config/kitty,
# ~/.config/k9s and ~/.config/krb5.conf (all start with "k" but are not KDE).
kde_paths() {
  local p
  for p in \
    "$HOME"/.config/plasma* \
    "$HOME"/.config/kwin* \
    "$HOME"/.config/kde* \
    "$HOME"/.config/kio* \
    "$HOME"/.config/kscreen* \
    "$HOME"/.config/ksplash* \
    "$HOME"/.config/kcm* \
    "$HOME"/.config/kate* \
    "$HOME"/.config/kactivity* \
    "$HOME"/.config/kwallet* \
    "$HOME"/.config/konsole* \
    "$HOME"/.config/klipper* \
    "$HOME"/.config/ktexteditor* \
    "$HOME"/.config/kglobalshortcutsrc \
    "$HOME"/.config/klaunchrc \
    "$HOME"/.config/kcminputrc \
    "$HOME"/.config/krunnerrc \
    "$HOME"/.config/ksmserverrc \
    "$HOME"/.config/dolphinrc \
    "$HOME"/.config/gwenviewrc \
    "$HOME"/.config/baloofilerc \
    "$HOME"/.config/akonadi* \
    "$HOME"/.config/Trolltech.conf \
    "$HOME"/.config/QtProject \
    "$HOME"/.config/qt5ct \
    "$HOME"/.config/qt6ct \
    "$HOME"/.config/gtk-3.0/settings.ini \
    "$HOME"/.config/gtk-4.0/settings.ini \
    "$HOME"/.cache/plasma* \
    "$HOME"/.cache/kwin* \
    "$HOME"/.cache/kde* \
    "$HOME"/.cache/krun* \
    "$HOME"/.cache/konsole* \
    "$HOME"/.cache/kscreen* \
    "$HOME"/.cache/dolphin* \
    "$HOME"/.cache/akonadi* \
    "$HOME"/.cache/baloo* \
    "$HOME"/.local/share/kwallet* \
    "$HOME"/.local/share/konsole \
    "$HOME"/.local/share/plasma* \
    "$HOME"/.local/share/kactivitymanagerd \
    "$HOME"/.local/share/kde* \
    "$HOME"/.local/share/kf5* \
    "$HOME"/.local/share/kxmlgui5* \
    "$HOME"/.local/share/klipper \
    "$HOME"/.local/share/dolphin \
    "$HOME"/.local/share/baloo* \
    "$HOME"/.local/share/akonadi* \
    "$HOME"/.local/state/plasma* \
    "$HOME"/.local/state/org_kde_*
  do
    [ -e "$p" ] && printf '%s\n' "$p"
  done || true

  # Orphan autostart entries created by KDE bits only (kdeconnect, wallet,
  # plasma services). Matched by name so other autostart entries stay.
  local f
  for f in "$HOME"/.config/autostart/*.desktop; do
    [ -e "$f" ] || continue
    case "$(basename "$f")" in
      *kde*|*plasma*|*kwin*|*kwallet*|*dolphin*)
        printf '%s\n' "$f"
        ;;
    esac
  done
}

TARGETS="$(kde_paths | sort -u)"

if [ -z "$TARGETS" ]; then
  echo "No KDE leftovers found in \$HOME. Nothing to do."
  exit 0
fi

echo "KDE/Qt leftovers that will be removed:"
echo "$TARGETS" | sed 's/^/  /'
echo
echo "Also: ~/.local/share/kwalletd — KWallet passwords are NOT recoverable."
echo "Shared files (mimeapps.list, thumbnails, XDG portals) are untouched."

# Deleting state under a live session is pointless: plasmashell/kwalletd
# rewrite it on exit. Warn, don't block (the script may be run from a TTY).
running=""
if command -v pgrep >/dev/null 2>&1; then
  for proc in plasmashell kwin_x11 kwin_wayland kwalletd5 kwalletd krunner; do
    if pgrep -x "$proc" >/dev/null 2>&1; then
      running="$running $proc"
    fi
  done
fi
if [ -n "$running" ]; then
  echo
  echo "WARNING: KDE processes still running:$running"
  echo "Log out of the Plasma session first — they recreate state while we delete."
fi

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

while IFS= read -r path; do
  [ -n "$path" ] || continue
  rm -rf -- "$path"
  echo "removed: $path"
done <<<"$TARGETS"

echo
echo "Done. Re-login (or reboot) so the GNOME session starts fully clean."