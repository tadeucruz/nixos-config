# Shared gaming stack (citadel + prothean + legion). Gamescope/session integration
# is handled separately by Jovian on citadel and legion; this covers the
# generic Steam features useful everywhere.
{ lib, pkgs, ... }:
let
  proton-ge = import ./proton-ge.nix {
    inherit (pkgs) lib stdenvNoCC fetchurl;
  };
  proton-cachyos = import ./proton-cachyos.nix {
    inherit (pkgs) lib stdenvNoCC fetchurl;
  };

in
{
  hardware = {
    xpadneo.enable = true;
  };

  programs = {
    gamemode.enable = true;

    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
      remotePlay.openFirewall = true;
      extraCompatPackages = [
        proton-ge
        proton-cachyos
      ];
    };
  };
}
