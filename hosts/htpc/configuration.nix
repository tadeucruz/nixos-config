# htpc — AMD desktop (CPU + GPU), SteamOS-like experience via Jovian.
{ config, pkgs, lib, username, hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/jovian.nix
  ];

  networking.hostName = hostname;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];

  # HDMI VRR is stuck behind an unmerged amdgpu patch (tracking upstream progress).
  boot.kernelParams = [
    "amdgpu.dcfeaturemask=0x400"
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # Kept here, not in hardware-configuration.nix, since nixos-generate-config overwrites that file.
  fileSystems."/".options = [ "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];
  fileSystems."/home".options = [ "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];
  fileSystems."/nix".options = [ "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];

  fileSystems."/GAMES" = {
    device = "/dev/disk/by-uuid/be622b96-26c5-4ff2-b740-7bab4dd6fa9d";
    fsType = "btrfs";
    options = [ "defaults" "noatime" "compress=zstd" "discard=async" "space_cache=v2" "nofail" ];
  };

  services.fstrim.enable = true;

  system.stateVersion = "26.05";
}
