# Applied to htpc and legion.
{ pkgs, username, ... }:
{
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = username;
      desktopSession = "plasma";
    };

    hardware.has.amd.gpu = true;
  };

  services.libinput.enable = true;

  # No display manager: Jovian's autoStart manages the session directly.
  services.desktopManager.plasma6.enable = true;

  nixpkgs.config.permittedInsecurePackages = [ "pnpm-9.15.9" ];
}
