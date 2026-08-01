# Shared gaming stack (Steam + controllers). Gamescope is managed by Jovian on legion, not here.
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

  # Proton on Wayland; force off Steam Deck identification since these are desktop machines.
  environment.sessionVariables = {
    PROTON_ENABLE_WAYLAND = "1";
    SteamDeck = "0";
  };
}
