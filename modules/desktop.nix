# Full desktop environment (used only on g15 — general-purpose laptop).
{ config, pkgs, lib, username, ... }:
{
  # KDE Plasma 6 on Wayland (default).
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;

  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  services.printing.enable = true;

  # Syncthing runs as a user service; web UI at http://localhost:8384
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
