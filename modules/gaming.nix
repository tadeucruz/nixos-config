# Shared gaming stack (Steam + controllers). Gamescope is managed by Jovian on htpc/legion, not here.
{ config, pkgs, lib, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  programs.gamemode.enable = true;

  hardware.steam-hardware.enable = true;
  hardware.xpadneo.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
  ];
}
