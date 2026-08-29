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

  jovian.steam.environment.STEAM_EXTRA_COMPAT_TOOLS_PATHS =
    lib.makeSearchPathOutput "steamcompattool" ""
      config.programs.steam.extraCompatPackages;

  services = {
    desktopManager.plasma6.enable = true;

    xserver.enable = false;
  };

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
