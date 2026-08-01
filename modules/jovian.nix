# Applied to legion only.
{ config, lib, pkgs, username, ... }:
{
  services.xserver.enable = false;
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = username;
      desktopSession = "plasma";
    };

    hardware.has.amd.gpu = true;
    steamos.useSteamOSConfig = true;
    decky-loader.enable = true;
  };

  # No display manager: Jovian's autoStart manages the session directly.
  services.desktopManager.plasma6.enable = true;

  # decky-loader's frontend build needs pnpm_9, which nixpkgs currently flags as
  # insecure (batch of CVEs affecting every pnpm version, not specific to this one).
  # Only used at build time, not run as a service, so the exposure is low.
  nixpkgs.config.permittedInsecurePackages = [ "pnpm-9.15.9" ];

  # Create Steam CEF debugging file if it doesn't exist for Decky Loader.
  systemd.services.steam-cef-debug = lib.mkIf config.jovian.decky-loader.enable {
    description = "Create Steam CEF debugging file";
    serviceConfig = {
      Type = "oneshot";
      User = config.jovian.steam.user;
      ExecStart = "/bin/sh -c 'mkdir -p ~/.steam/steam && [ ! -f ~/.steam/steam/.cef-enable-remote-debugging ] && touch ~/.steam/steam/.cef-enable-remote-debugging || true'";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
