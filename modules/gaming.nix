# Shared gaming stack (Steam + controllers).
# Gamescope is intentionally not configured here — Jovian manages it on htpc/legion.
{ config, pkgs, lib, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  programs.gamemode.enable = true;

  # Controller support
  hardware.steam-hardware.enable = true; # udev rules for Steam Controller / Deck
  hardware.xpadneo.enable = true;        # Xbox controllers over Bluetooth

  environment.systemPackages = with pkgs; [
    mangohud
  ];
}
