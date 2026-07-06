# Jovian SteamOS-like session with KDE as fallback desktop.
# Applied to htpc and legion.
{ pkgs, username, ... }:
{
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = username;
      desktopSession = "plasma"; # "Exit to Desktop" lands on KDE
    };

    hardware.has.amd.gpu = true;

    # decky-loader = {
    #   enable = true;
    #   user = username; # plugins must run as the same user as Steam
    # };
  };

  services.libinput.enable = true;

  # KDE available as the desktop session when exiting Steam.
  # Note: no display manager — Jovian's autoStart manages the session directly.
  services.desktopManager.plasma6.enable = true;

  nixpkgs.config.permittedInsecurePackages = [ "pnpm-9.15.9" ];
}
