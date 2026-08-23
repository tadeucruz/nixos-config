# citadel's kernel: vanilla 7.2.0 + OpenGamingCollective's monolithic.patch.
#
# Why fetchurl of the vanilla tarball + patch instead of OGC's git archive tree:
# fetchzip's unpacked-tree hash VARIES BY NIX VERSION (nix 2.34.8 computed a
# different hash than citadel's nix for the same v7.2-ogc4 archive). fetchurl
# hashes are pure content, identical on every nix version.
#
# The vanilla base hash equals nixpkgs's own linux_7_2 pin; the patch applies
# cleanly against linux-7.2.0 (verified with git apply --check). What the patch
# buys citadel: AMD HDMI 2.1 VRR/ALLM (absent from vanilla 7.2) plus
# hardware-ID-gated handheld drivers (harmless here). No game scheduler included.
#
# Decoupled from nixpkgs's linux_latest: nixpkgs updates freely, the kernel only
# moves when a new OGC release is picked up. Bump via scripts/update-ogc-kernel.sh
# (CI: .github/workflows/check-ogc-update.yml).
{ pkgs, lib, ... }:

let
  ogcRelease = "v7.2-ogc4";
  ogcBase = "7.2"; # kernel base (major.minor) the OGC release was generated against
  ogcModDir = "7.2.0"; # Makefile version of the base tree

  ogcBaseHash = "sha256-+f7z0UwN9TgZAm9L50RZg1wqCw3L9bW72eoZ8IKUArM=";
  ogcPatchHash = "sha256-HFjMBRubCRy+6QYQxir1BvK9MkYjMuvC++TI4z63Mr8=";

  ogcBaseSrc = pkgs.fetchurl {
    url = "https://cdn.kernel.org/pub/linux/kernel/v${lib.versions.major ogcBase}.x/linux-${ogcBase}.tar.xz";
    hash = ogcBaseHash;
  };

  ogcPatch = pkgs.fetchurl {
    url = "https://github.com/OpenGamingCollective/linux/releases/download/${ogcRelease}/monolithic.patch";
    hash = ogcPatchHash;
  };

  ogcKernel = pkgs.buildLinux {
    pname = "linux-ogc";
    # Strip the tag's "v" prefix so version stays parseable by kernelAtLeast.
    version = lib.removePrefix "v" ogcRelease;
    modDirVersion = ogcModDir;
    src = ogcBaseSrc;
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
      { name = "opengamingcollective-${ogcRelease}"; patch = ogcPatch; }
    ];
  };
in
pkgs.linuxPackagesFor ogcKernel