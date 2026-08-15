# NixOS's linuxPackages_testing with OpenGamingCollective's monolithic patch applied —
# carries the official upstream HDMI 2.1 VRR/ALLM patch series (still not merged
# anywhere upstream, see CLAUDE.md) plus assorted gaming-handheld driver patches
# (Steam Deck, ROG Ally, MSI Claw, AYN, OneXPlayer) that are hardware-ID-gated and
# harmless on citadel's desktop hardware.
#
# Still an RC-track kernel (7.2-rc7) — the reboot/shutdown hang investigated in
# project memory applies here too. Traded back in for VRR since OGC's build already
# does the amdgpu_dm.c porting work (no file-split mismatch like amd-staging-drm-next)
# and is actively maintained — bump `ogcRelease` when they cut a new tag.
{ pkgs, ... }:

let
  ogcRelease = "v7.2-rc7-ogc3";

  ogcMonolithicPatch = pkgs.fetchurl {
    url = "https://github.com/OpenGamingCollective/linux/releases/download/${ogcRelease}/monolithic.patch";
    hash = "sha256-GuHmY/+ci3AFCedCxD5JNs+aGfkfDabr8u4vJAQuDKU=";
  };

  # `linux_testing.override` can't actually change `version`/`src` — mainline.nix
  # recomputes both internally on every call regardless of what's overridden (only
  # non-recomputed args like `kernelPatches` pass through). Build directly instead,
  # reusing linux_testing's own fetched source and default kernelPatches.
  testingKernel = pkgs.buildLinux {
    pname = "linux-ogc";
    version = "7.2-rc7-ogc3";
    modDirVersion = "7.2.0-rc7"; # must match `make kernelversion` for this src exactly
    src = pkgs.linux_testing.src;
    kernelPatches = pkgs.linux_testing.kernelPatches ++ [
      {
        name = "opengamingcollective-${ogcRelease}";
        patch = ogcMonolithicPatch;
      }
    ];
  };
in
pkgs.linuxPackagesFor testingKernel
