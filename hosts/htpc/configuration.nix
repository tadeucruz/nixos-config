# htpc — AMD desktop (CPU + GPU), SteamOS-like experience via Jovian.
{ config, pkgs, lib, username, hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/jovian.nix
  ];

  networking.hostName = hostname;

  # CachyOS RC kernel: carries the out-of-tree HDMI 2.1 VRR/FRL patchset that
  # hasn't landed in mainline amdgpu yet (confirmed missing on linuxPackages_testing
  # 7.2-rc1 — no vrr_capable property on the HDMI connector at all). Provided by
  # the nix-cachyos-kernel flake input (pinned overlay, cached). Risk accepted.
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-rc;

  # ryzen_smu doesn't build against this RC kernel (cpuid_eax/cpuid_ebx
  # implicit-declaration errors — the out-of-tree module hasn't caught up
  # with a kernel header change in 7.2-rc1 yet).
  hardware.cpu.amd.ryzen-smu.enable = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];

  # HDMI FRL/VRR (TV connected via HDMI, not DisplayPort).
  # "dcfeaturemask" is the real param name (docs.kernel.org/gpu/amdgpu) — NOT
  # "dc_feature_mask". "hdmi_vrr_desktop_mode" and "allm_mode" don't exist as
  # amdgpu params at all (confirmed both by kernel docs and by dmesg logging
  # them as "unknown parameter ignored"); they were reported by some articles
  # about a not-yet-merged patch series, dropped here since they're dead weight.
  boot.kernelParams = [
    "amdgpu.dcfeaturemask=0x400"
  ];

  # --- AMD GPU ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # Tuning for the btrfs subvolumes defined in hardware-configuration.nix.
  # Kept here (not there) since that file gets overwritten by nixos-generate-config.
  # NixOS merges fileSystems.<mount>.options across modules, so this appends
  # to the existing options (e.g. subvol=home) instead of replacing them.
  fileSystems."/".options = [ "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];
  fileSystems."/home".options = [ "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];
  fileSystems."/nix".options = [ "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];

  # --- Extra data drive ---
  fileSystems."/GAMES" = {
    device = "/dev/disk/by-uuid/be622b96-26c5-4ff2-b740-7bab4dd6fa9d";
    fsType = "btrfs";
    options = [ "defaults" "noatime" "compress=zstd" "discard=async" "space_cache=v2" "nofail" ];
  };

  # Periodic TRIM as a backup to discard=async on all btrfs mounts.
  services.fstrim.enable = true;

  system.stateVersion = "26.05";
}
