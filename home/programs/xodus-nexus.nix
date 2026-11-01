# Xodus Nexus — Xbox / Microsoft Store launcher for Linux, packaged from the
# upstream AppImage in modules/xodus-nexus.nix (pinned + auto-bumped via
# `scripts/update.sh xodus`, surfaced by the update workflow).
#
# Note: the Nexus game runtime is downloaded in-app (Settings → Update
# runtime) and lives outside the store, so it survives rebuilds but is wiped
# by scripts/reset-home.sh.
{
  pkgs,
  lib,
  ...
}:
{
  home.packages = [
    (import ../../modules/xodus-nexus.nix { inherit pkgs lib; })
  ];
}
