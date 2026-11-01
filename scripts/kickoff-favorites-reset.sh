#!/usr/bin/env bash
# Re-seed Kickoff favorites from the declarative list in home/desktop/kde.nix.
#
# Plasma 6 kickoff reads favorites from the KActivities DB once
# favoritesPortedToKAstats=true, and portOldFavorites() only runs while that
# DB has no favorites — so editing the config list alone does nothing on an
# existing home. This clears the launcher favorites (one-time per host) so the
# next kickoff start ports the declared list into the DB. Safe to re-run.
set -euo pipefail

db="$HOME/.local/share/kactivitymanagerd/resources/database"
appletsrc="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

sql() {
  if command -v sqlite3 >/dev/null 2>&1; then
    sqlite3 "$@"
  else
    nix run nixpkgs#sqlite -- "$@"
  fi
}

ids=$(awk '
  /^\[Containments\]\[[0-9]+\]\[Applets\]\[[0-9]+\]$/ { header = $0 }
  /^plugin=org\.kde\.plasma\.kickoff$/ { split(header, a, /[^0-9]+/); print a[2], a[3]; exit }
' "$appletsrc")
if [ -z "$ids" ]; then
  echo "no kickoff applet found in $appletsrc" >&2
  exit 1
fi
containment=${ids%% *}
applet=${ids##* }

# Collect stale favorite orderings first — all parsing happens before the
# services go down so a parse failure never leaves a broken session
groups=$(grep -oP '^\[Favorites-[^]]+\]' "$HOME/.config/kactivitymanagerd-statsrc" 2>/dev/null | tr -d '[]' || true)

systemctl --user stop plasma-plasmashell.service plasma-kactivitymanagerd.service

if [ -f "$db" ]; then
  sql "$db" "DELETE FROM ResourceLink
             WHERE usedActivity = ':global'
               AND initiatingAgent = 'org.kde.plasma.favorites.applications';"
fi

for group in $groups; do
  kwriteconfig6 --file kactivitymanagerd-statsrc --group "$group" --key ordering --delete
done

# Port guard off so kickoff imports the declarative list on next start
kwriteconfig6 --file "$appletsrc" \
  --group Containments --group "$containment" \
  --group Applets --group "$applet" \
  --group Configuration --group General \
  --key favoritesPortedToKAstats false

systemctl --user start plasma-kactivitymanagerd.service plasma-plasmashell.service
echo "done — kickoff now seeds the favorites from home/desktop/kde.nix"
