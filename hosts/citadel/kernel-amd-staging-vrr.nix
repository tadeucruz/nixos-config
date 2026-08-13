# Kernel built from AMD's amd-staging-drm-next branch with the official HDMI 2.1
# VRR/ALLM patch series applied on top (posted upstream 2026-08-06, not yet merged
# anywhere — not in mainline, not in amd-staging-drm-next itself). See CLAUDE.md for
# the patch series link.
#
# amd-staging-drm-next is AMD's internal display-driver development branch, not a
# release — expect churn/instability unrelated to VRR. Pinned to a specific commit
# rather than tracking the branch, since it moves fast and isn't meant to be reproducible.
{ pkgs, ... }:

let
  vrrPatches = [
    {
      name = "amdgpu-2.1-freesync-amd-vsdb";
      patch = ../../patches/amdgpu-hdmi21-vrr-allm/0001-drm-amd-display-Add-2.1-FreeSync-support-for-AMD-VSDB.patch;
    }
    {
      name = "drm-edid-hf-vsdb-gaming-caps";
      patch = ../../patches/amdgpu-hdmi21-vrr-allm/0002-drm-edid-parse-HDMI-2.1-gaming-ALLM-VRR-capabilities.patch;
    }
    {
      name = "amdgpu-hdmi21-vrr-hf-vsdb";
      patch = ../../patches/amdgpu-hdmi21-vrr-allm/0003-drm-amd-display-Add-HDMI-2.1-VRR-support-from-HF-VSDB.patch;
    }
    {
      name = "amdgpu-hdmi21-allm";
      patch = ../../patches/amdgpu-hdmi21-vrr-allm/0004-drm-amd-display-Add-HDMI-ALLM-support.patch;
    }
  ];

  amdStagingVrrKernel = pkgs.buildLinux {
    pname = "linux-amd-staging-vrr";
    version = "7.2.0-amd-staging-vrr-20260812";
    modDirVersion = "7.2.0-amd-staging-vrr-20260812";

    # amd-staging-drm-next @ 2026-08-12
    src = pkgs.fetchgit {
      url = "https://gitlab.freedesktop.org/agd5f/linux.git";
      rev = "21c50d41af7c46e138b542dba2dcf6d2a978ae99";
      hash = "sha256-w09lxf6VIMN1140OZBNuP+O7bQsHzVUn5gYSinXUKX0=";
    };

    kernelPatches = vrrPatches;
  };
in
pkgs.linuxPackagesFor amdStagingVrrKernel
