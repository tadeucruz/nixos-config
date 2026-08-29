# Shared gaming stack (citadel + prothean + legion). Gamescope/session integration
# is handled separately by Jovian on citadel and legion; this covers the
# generic Steam features useful everywhere.
{ lib, pkgs, ... }:
let
  # Two Proton flavors, both pinned to the latest upstream releases (nixpkgs's
  # proton-ge-bin lags and GE-Proton11-3 has the icuuc.dll.u_setMemoryFunctions_65
  # abort — upstream #651, fixed in 11-4). Pick per game in Steam. Bumps go
  # through scripts/update.sh, surfaced by check-updates.yml.
  proton-ge = import ./proton-ge.nix {
    inherit (pkgs) lib stdenvNoCC fetchurl;
  };
  proton-cachyos = import ./proton-cachyos.nix {
    inherit (pkgs) lib stdenvNoCC fetchurl;
  };

in
{
  hardware = {
    steam-hardware.enable = true;
    xpadneo.enable = true;
  };

  programs = {
    gamemode.enable = true;

    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
      remotePlay.openFirewall = true;
      # GE-Proton + Proton-CachyOS managed by nix; wired into the Steam wrapper
      # via STEAM_EXTRA_COMPAT_TOOLS_PATHS.
      extraCompatPackages = [
        proton-ge
        proton-cachyos
      ];
    };
  };
}
