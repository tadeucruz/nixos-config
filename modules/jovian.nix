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
