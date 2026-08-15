# NixOS's stable linuxPackages_latest with OpenGamingCollective's monolithic patch
# applied — adds the Lenovo WMI driver stack (drivers/platform/x86/lenovo/*: battery
# charge limiting, CPU/GPU tunables) that upstream doesn't have yet, on top of a
# released kernel (7.1.8, no RC — no reboot-hang risk like citadel's kernel has).
# See CLAUDE.md.
{ pkgs, ... }:

let
  ogcRelease = "v7.1.8-ogc1";

  ogcMonolithicPatch = pkgs.fetchurl {
    url = "https://github.com/OpenGamingCollective/linux/releases/download/${ogcRelease}/monolithic.patch";
    hash = "sha256-kDZrVwmEdSK5KDxVfhRJrGQuz5pKsETEwLSdtIKEjIs=";
  };

  # linux_latest.override can't change version/src (see hosts/citadel/kernel-ogc-vrr.nix
  # for why) — build directly, reusing linux_latest's own fetched source.
  latestKernel = pkgs.buildLinux {
    pname = "linux-ogc";
    version = "7.1.8-ogc1";
    modDirVersion = "7.1.8";
    src = pkgs.linux_latest.src;
    kernelPatches = pkgs.linux_latest.kernelPatches ++ [
      {
        name = "opengamingcollective-${ogcRelease}";
        patch = ogcMonolithicPatch;
      }
    ];
  };
in
pkgs.linuxPackagesFor latestKernel
