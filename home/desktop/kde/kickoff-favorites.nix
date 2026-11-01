# Kickoff application-menu favorites, enforced declaratively.
#
# Plasma 6 kickoff reads favorites from the KActivities DB (per-activity
# links), not from the appletsrc — the `favorites` config key is only a
# migration seed, consumed once while the DB is empty. There is no config-only
# path for this upstream (plasma-manager tried and dropped it in PR #238 and
# PR #642; issue #539 is still open), so this module reconciles the KAstats
# links through kactivitymanagerd's own D-Bus API on every login: the running
# kickoff picks the changes up live and the declared list always wins.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.kickoffFavorites;

  agent = "org.kde.plasma.favorites.applications";
  activity = ":global";
  qdbus = lib.getExe' pkgs.kdePackages.qttools "qdbus";
  sqlite = "${pkgs.sqlite}/bin/sqlite3";
  kwriteconfig = lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6";

  # Menu IDs normalize to `applications:<id>` URIs — the form kickoff stores
  # in the DB and the ordering file (AppEntry::id()). Other URIs pass through.
  resolved = map (f: if lib.hasInfix "://" f then f else "applications:${f}") cfg.favorites;
  resolvedArgs = lib.concatMapStringsSep " " (f: "'${f}'") resolved;
  resolvedCsv = lib.concatStringsSep "," resolved;
in
{
  options.programs.kickoffFavorites.favorites = lib.mkOption {
    type = lib.types.nullOr (lib.types.listOf lib.types.str);
    default = null;
    example = [ "steam.desktop" ];
    description = "Kickoff application menu favorites, in order.";
  };

  config = lib.mkIf (cfg.favorites != null) {
    programs.plasma.startup.startupScript."kickoff-favorites" = {
      runAlways = true;
      priority = 5;
      text = ''
        db="$HOME/.local/share/kactivitymanagerd/resources/database"
        statsrc="$HOME/.config/kactivitymanagerd-statsrc"
        agent="${agent}"
        activity="${activity}"

        # Unlink whatever the DB currently has, then link the declared list.
        current=$(${sqlite} "$db" "SELECT targettedResource FROM ResourceLink WHERE usedActivity='$activity' AND initiatingAgent='$agent';" 2>/dev/null || true)
        for res in $current; do
          ${qdbus} org.kde.ActivityManager /ActivityManager/Resources/Linking \
            org.kde.ActivityManager.ResourcesLinking.UnlinkResourceFromActivity "$agent" "$res" "$activity" || true
        done
        for res in ${resolvedArgs}; do
          ${qdbus} org.kde.ActivityManager /ActivityManager/Resources/Linking \
            org.kde.ActivityManager.ResourcesLinking.LinkResourceToActivity "$agent" "$res" "$activity" || true
        done

        # Favorites ordering lives in kactivitymanagerd-statsrc, keyed by the
        # kickoff applet instance; rewrite every kickoff group on file.
        order="${resolvedCsv}"
        grep -o '^\[Favorites-org\.kde\.plasma\.kickoff\.favorites\.instance-[^]]*\]' "$statsrc" 2>/dev/null |
          tr -d '[]' |
          while IFS= read -r group; do
            ${kwriteconfig} --file kactivitymanagerd-statsrc --group "$group" --key ordering "$order"
          done
      '';
    };
  };
}
