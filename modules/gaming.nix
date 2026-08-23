# Shared gaming stack (citadel + prothean + legion). Gamescope/session integration
# is handled separately by Jovian on citadel and legion; this covers the
# generic Steam features useful everywhere.
{ lib, pkgs, ... }:
let
  # Two Proton flavors, both pinned to the latest upstream releases (nixpkgs's
  # proton-ge-bin lags and GE-Proton11-3 has the icuuc.dll.u_setMemoryFunctions_65
  # abort — upstream #651, fixed in 11-4). Pick per game in Steam. Bumps go
  # through scripts/update-proton.sh, surfaced by check-proton-update.yml.
  proton-ge = import ./proton-ge.nix {
    inherit (pkgs) lib stdenvNoCC fetchurl;
  };
  proton-cachyos = import ./proton-cachyos.nix {
    inherit (pkgs) lib stdenvNoCC fetchurl;
  };

  # scx_lavd 1.1.3 (current nixpkgs) has a known regression: repeated
  # runnable-task stalls that freeze the game for 30-44s (verified on citadel:
  # Cyberpunk's GameThread failed to run for 30s+, watchdog kills the scheduler).
  # Upstream sched-ext/scx#3750 — resolved by downgrading to 1.1.2. Pin the rust
  # schedulers to 1.1.2 (hashes from the nixpkgs that shipped it) until a fixed
  # release lands in nixpkgs.
  scx-rustscheds-112 = pkgs.scx.rustscheds.overrideAttrs (old: {
    version = "1.1.2";
    src = pkgs.fetchFromGitHub {
      owner = "sched-ext";
      repo = "scx";
      tag = "v1.1.2";
      hash = "sha256-igrmrfimVOEJnFxMr9ghN6lAHwEBSFLLVrB2MQ72PXI=";
    };
    cargoHash = "sha256-CTEVdvw6aG/fFas2Fk3x9o4Sp2k3lHO/OLwUM8t9UjE=";
  });
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

  # scx_lavd (sched-ext game scheduler) on all three hosts. On citadel/legion
  # Jovian forces systemd.services.scx.wantedBy = [] (mkForce, priority 50)
  # because steamos-manager is the supposed owner — but it never actually starts
  # it (verified: sched_ext stayed disabled during a game on legion). Make the
  # boot service authoritative everywhere via mkOverride 0 (beats mkForce).
  # scheduler uses mkDefault so Jovian's plain definition (priority 100) wins on
  # citadel/legion without a "unique option defined twice" conflict. package uses
  # mkForce to beat Jovian's plain package (the pinned 1.1.2).
  services.scx = {
    enable = true;
    package = lib.mkForce scx-rustscheds-112;
    scheduler = lib.mkDefault "scx_lavd";
  };

  systemd.services.scx.wantedBy = lib.mkOverride 0 [ "multi-user.target" ];
}
