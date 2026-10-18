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
# from the OGC source via customPackage. Reuse linux_latest's configfile to
# keep nixpkgs's full config (ntsync, amdgpu, etc.).
pkgs.linuxKernel.customPackage {
  version = ogcVersion;
  src = ogcSrc;
  configfile = pkgs.linux_latest.configfile;
}
