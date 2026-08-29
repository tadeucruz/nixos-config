# citadel's kernel: nixpkgs's linux_latest + OpenGamingCollective's
# monolithic.patch applied on top.
#
# The OGC patch is the only thing fetched via fetchurl (from the GitHub release
# asset). The vanilla base comes straight from nixpkgs's linux_latest package —
# no fetchzip/fetchurl of the kernel tarball, so no unpacked-tree hash variation
# across nix versions (fetchurl pure-content hashes are version-independent).
#
# What the patch buys citadel: AMD HDMI 2.1 VRR/ALLM (absent from vanilla) plus
# hardware-ID-gated handheld drivers (harmless here). No game scheduler included.
#
# Decoupled from nixpkgs's linux_latest: nixpkgs updates freely, the kernel only
# moves when a new OGC release is picked up. Bump via scripts/update.sh ogc
# (CI: .github/workflows/check-updates.yml). scripts/update.sh skips the bump
# with a warning while the OGC release's base differs from linux_latest (the
# patch may not apply), applying automatically once nixpkgs catches up.
{ pkgs, lib, ... }:

let
  ogcRelease = "v7.2-ogc9";

  ogcPatch = pkgs.fetchurl {
    url = "https://github.com/OpenGamingCollective/linux/releases/download/${ogcRelease}/monolithic.patch";
    hash = "sha256-ofzUmMfmz65WqrevKvIv8pGYdIl6izXhp5WsoMwn2W4=";
  };

  ogcKernel = pkgs.linux_latest.override {
    # Keep nixpkgs's default patches (bridge_stp_helper, request_key_helper)
    # and append the OGC one.
    kernelPatches = pkgs.linux_latest.kernelPatches ++ [
      { name = "opengamingcollective-${ogcRelease}"; patch = ogcPatch; }
    ];
  };
in
pkgs.linuxPackagesFor ogcKernel