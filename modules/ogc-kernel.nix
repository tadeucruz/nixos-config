{ pkgs, lib, ... }:

let
  ogcRelease = "v7.2.9-ogc2";

  ogcPatch = pkgs.fetchurl {
    url = "https://github.com/OpenGamingCollective/linux/releases/download/${ogcRelease}/monolithic.patch";
    hash = "sha256-bRmTWgB7quM3NRslMfQPkj1DqgUBQAg3NIYKS1of6Z4=";
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
