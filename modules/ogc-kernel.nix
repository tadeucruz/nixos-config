{ pkgs, lib, ... }:

let
  ogcRelease = "v7.2.9-ogc7";

  # OGC renumbers the kernel (Makefile VERSION=7), so the source tarball
  # reports e.g. 7.2.9. Built directly from OGC's git-archive source (patches
  # already applied), no nixpkgs patches on top.
  ogcVersion = lib.removePrefix "v" (lib.head (lib.splitString "-ogc" ogcRelease));

  ogcSrc = pkgs.fetchurl {
    url = "https://github.com/OpenGamingCollective/linux/archive/refs/tags/${ogcRelease}.tar.gz";
    hash = "sha256-6ibBkSHdLxzrwK8K92WGfARDq4hMKig8vGNAytGFn+M=";
  };
in
# linux_latest.override does not propagate src/version, so build the kernel
# from the OGC source via buildLinux (generic.nix) — this keeps nixpkgs's
# common config (ntsync, amdgpu) and the `features` attrset NixOS asserts on
# (efiBootStub, netfilterRPFilter, ia32Emulation).
pkgs.linuxPackagesFor (pkgs.buildLinux {
  src = ogcSrc;
  version = ogcVersion;
  modDirVersion = lib.versions.pad 3 ogcVersion;
  kernelPatches = [ ];
})
