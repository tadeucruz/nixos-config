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
# (CI: .github/workflows/check-updates.yml). If OGC ever releases against a
# different base, the linux_latest base below must be updated manually.
{ pkgs, lib, ... }:

let
  ogcRelease = "v7.2.1-ogc2";

  ogcPatch = pkgs.fetchurl {
    url = "https://github.com/OpenGamingCollective/linux/releases/download/${ogcRelease}/monolithic.patch";
    hash = "sha256-rKHdJWkMBPmyP2g0hUqKH2je8TFiNEDUq5pafVYI1PU=";
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