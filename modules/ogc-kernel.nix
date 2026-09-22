{ pkgs, lib, ... }:

let
  ogcRelease = "v7.2.6-ogc3";

  ogcPatch = pkgs.fetchurl {
    url = "https://github.com/OpenGamingCollective/linux/releases/download/${ogcRelease}/monolithic.patch";
    hash = "sha256-s/7fJG2z7Ec4A6K2Vzv+MAuM89gBJo/AKDxIA6HdVus=";
  };

  ogcKernel = pkgs.linux_latest.override {
    # Keep nixpkgs's default patches (bridge_stp_helper, request_key_helper)
    # and append the OGC one.
    kernelPatches = pkgs.linux_latest.kernelPatches ++ [
      {
        name = "opengamingcollective-${ogcRelease}";
        patch = ogcPatch;
      }
    ];
  };
in
pkgs.linuxPackagesFor ogcKernel
