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
let
  xodus = import ../../modules/xodus-nexus.nix { inherit pkgs lib; };
in
{
  home.packages = [ xodus ];

  # Steam/desktop shortcut helper. Upstream's `--launch-game` only works when
  # the primary launcher instance is already running: a cold start with that
  # flag exits after <1s without launching the game (and without an error).
  # So bring the launcher up first, wait for its single-instance lock, then
  # hand the launch request to the running instance — that path works.
  #
  #   xodus-nexus-launch <game id>    launch that game (or add it to Steam)
  #   xodus-nexus-launch              just open the launcher
  home.file.".local/bin/xodus-nexus-launch" = {
    executable = true;
    text = ''
      #!/bin/sh
      set -u
      profile="''${XODUS_NEXUS_PROFILE:-$HOME/.config/xodus-nexus}"
      launcher=${lib.escapeShellArg (lib.getExe xodus)}
      if [ "$#" -lt 1 ]; then
        exec "$launcher" --nexus-profile "$profile"
      fi
      game="$1"
      if ! pgrep -f "${xodus}/bin/.xodus-nexus-wrapped" >/dev/null 2>&1; then
        setsid "$launcher" --nexus-profile "$profile" >/dev/null 2>&1 &
        i=0
        while [ "$i" -lt 150 ] && [ ! -e "$profile/SingletonLock" ]; do
          sleep 0.2
          i=$((i + 1))
        done
        sleep 2
      fi
      exec "$launcher" --nexus-profile "$profile" --launch-game "$game"
    '';
  };
}