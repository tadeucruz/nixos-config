# NixOS's own RC/testing kernel (linuxPackages_testing) with the official upstream
# HDMI 2.1 VRR/ALLM patch series applied. See CLAUDE.md for the patch series link.
#
# The series (patches/amdgpu-hdmi21-vrr-allm/) targets AMD's amd-staging-drm-next
# branch, which has already split amdgpu_dm.c into separate files that don't exist
# on mainline yet. patches/amdgpu-hdmi21-vrr-allm-testing-kernel/ carries the same
# logic hand-ported to apply against linux_testing's still-monolithic amdgpu_dm.c —
# see 0004's own header comment for exactly what was ported and why.
{ pkgs, ... }:

let
  vrrPatches = [
    {
      name = "drm-edid-hf-vsdb-gaming-caps";
      patch = ../../patches/amdgpu-hdmi21-vrr-allm-testing-kernel/0001-drm-edid-hf-vsdb-gaming-caps.patch;
    }
    {
      name = "info-packet-vtem-helper";
      patch = ../../patches/amdgpu-hdmi21-vrr-allm-testing-kernel/0002-info-packet-vtem-helper.patch;
    }
    {
      name = "amdgpu-dm-commit-planes-vsp-infopacket";
      patch = ../../patches/amdgpu-hdmi21-vrr-allm-testing-kernel/0003-amdgpu-dm-commit-planes-vsp-infopacket.patch;
    }
    {
      name = "amdgpu-dm-manual-port-vrr-allm-freesync";
      patch = ../../patches/amdgpu-hdmi21-vrr-allm-testing-kernel/0004-amdgpu-dm-manual-port-vrr-allm-freesync.patch;
    }
  ];

  # Mirrors pkgs/top-level/linux-kernels.nix's own `linux_testing` definition, plus
  # our patches — can't just `linux_testing.override`, since branch="testing" bakes
  # `src`/`version` in after any override is merged.
  testingKernel = pkgs.callPackage "${pkgs.path}/pkgs/os-specific/linux/kernel/mainline.nix" {
    branch = "testing";
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
    ] ++ vrrPatches;
  };
in
pkgs.linuxPackagesFor testingKernel
