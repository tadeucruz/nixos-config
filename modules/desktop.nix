# Full desktop environment (used on citadel and g15).
{ config, pkgs, lib, username, ... }:
{
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;

  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  services.printing.enable = true;

  services.syncthing = {
    enable = true;
    user = username;
    dataDir = "/home/${username}";
  };

  nixpkgs.config.permittedInsecurePackages = [ "electron-39.8.10" ];

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
  ];
}
