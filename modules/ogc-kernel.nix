{ pkgs, lib, ... }:

let
  ogcRelease = "v7.2.6-ogc1";

  ogcPatch = pkgs.fetchurl {
    url = "https://github.com/OpenGamingCollective/linux/releases/download/${ogcRelease}/monolithic.patch";
    hash = "sha256-MSyVJEUkGufCBLEp1L1S6q9wale3SCEk3S08qGoy5OU=";
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
