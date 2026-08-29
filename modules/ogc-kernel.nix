# citadel's kernel: nixpkgs's vanilla 7.2 (linux_7_2) + OpenGamingCollective's
# monolithic.patch applied on top.
#
# The OGC patch is the only thing fetched via fetchurl (from the GitHub release
# asset). The vanilla base comes straight from nixpkgs's linux_7_2 package — no
# fetchzip/fetchurl of the kernel tarball, so no unpacked-tree hash variation
# across nix versions (fetchurl pure-content hashes are version-independent).
#
# Note: linux_7_2 tracks the latest 7.2.x patch release in nixpkgs. The OGC
# patch is generated against exactly 7.2.0, so if nixpkgs bumps linux_7_2 to
# 7.2.1+ the patch may stop applying and the build fails — dealt with manually
# when it happens (or wait for an OGC release on that base).
#
# What the patch buys citadel: AMD HDMI 2.1 VRR/ALLM (absent from vanilla 7.2)
# plus hardware-ID-gated handheld drivers (harmless here). No game scheduler
# included.
#
# Decoupled from nixpkgs's linux_latest: nixpkgs updates freely, the kernel only
# moves when a new OGC release is picked up. Bump via scripts/update.sh ogc
# (CI: .github/workflows/check-updates.yml). If OGC ever releases against a
# different base (e.g. v7.3), the linux_7_2 base below must be updated manually.
{ pkgs, lib, ... }:

let
  ogcRelease = "v7.2-ogc7";

  ogcPatch = pkgs.fetchurl {
    url = "https://github.com/OpenGamingCollective/linux/releases/download/${ogcRelease}/monolithic.patch";
    hash = "sha256-BZ06Jz3xbG0bYq+BLfSFUfEhkUzJC+JPHZa+WepKvcM=";
  };

  ogcKernel = pkgs.linux_7_2.override {
    # Keep nixpkgs's default patches (bridge_stp_helper, request_key_helper)
    # and append the OGC one.
    kernelPatches = pkgs.linux_7_2.kernelPatches ++ [
      { name = "opengamingcollective-${ogcRelease}"; patch = ogcPatch; }
    ];
  };
in
pkgs.linuxPackagesFor ogcKernel