# Applied to citadel and legion.
{
  config,
  lib,
  pkgs,
  username,
  ...
}:
{
  jovian = {
    decky-loader.enable = true;

    hardware.has.amd.gpu = true;

    steam = {
      autoStart = true;
      desktopSession = "plasma";
      enable = true;
      user = username;
    };

    steamos.useSteamOSConfig = true;
  };

  # steam-launcher execs a hardcoded steam store path baked into
  # gamescope-session, so the STEAM_EXTRA_COMPAT_TOOLS_PATHS that
  # programs.steam.extraCompatPackages adds to the nixos steam wrapper's FHS
  # profile never reaches the Steam client here. steam-launcher.service does
  # EnvironmentFile=%t/gamescope-environment, and that file is a dump of the
  # gamescope session env after sourcing /etc/xdg/gamescope-session/environment
  # (jovian.steam.environment) — so inject the variable there too.
  jovian.steam.environment.STEAM_EXTRA_COMPAT_TOOLS_PATHS =
    lib.makeSearchPathOutput "steamcompattool" "" config.programs.steam.extraCompatPackages;

  services = {
    desktopManager.plasma6.enable = true;

    xserver.enable = false;
  };

  # Create Steam CEF debugging file if it doesn't exist for Decky Loader.
  systemd.services.steam-cef-debug = lib.mkIf config.jovian.decky-loader.enable {
    description = "Create Steam CEF debugging file";
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/sh -c 'mkdir -p ~/.steam/steam && [ ! -f ~/.steam/steam/.cef-enable-remote-debugging ] && touch ~/.steam/steam/.cef-enable-remote-debugging || true'";
      Type = "oneshot";
      User = config.jovian.steam.user;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
