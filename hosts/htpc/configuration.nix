# htpc — AMD desktop (CPU + GPU), SteamOS-like experience via Jovian.
{ config, pkgs, lib, username, hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/jovian.nix
  ];

  networking.hostName = hostname;

  # Back on the default NixOS kernel (dropped the CachyOS RC kernel that carried
  # an out-of-tree HDMI 2.1 VRR/FRL patchset). VRR on this HDMI-connected TV is
  # unavailable until that lands in mainline amdgpu (tracking: Linux 7.2).
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
