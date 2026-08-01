# Shared gaming stack (citadel + g15 + legion). Gamescope/session integration
# is handled separately by Jovian on legion; this covers the generic Steam
# features useful everywhere.
{ pkgs, ... }:
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
}
