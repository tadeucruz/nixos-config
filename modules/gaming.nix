# Shared gaming stack (Steam + gamescope + controllers).
{ config, pkgs, lib, ... }:
{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.gamemode.enable = true;

  # Controller support
  hardware.steam-hardware.enable = true; # udev rules for Steam Controller / Deck
  hardware.xpadneo.enable = true;        # Xbox controllers over Bluetooth

  environment.systemPackages = with pkgs; [
    mangohud
    gamescope
  ];
}
