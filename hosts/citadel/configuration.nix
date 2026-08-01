# citadel — AMD desktop (CPU + GPU). Gaming PC, normal desktop like g15.
{ config, pkgs, lib, username, hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/desktop.nix
    ../../modules/gaming.nix
    ../../modules/btrfs-tuning.nix
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

  fileSystems."/GAMES" = {
    device = "/dev/disk/by-uuid/be622b96-26c5-4ff2-b740-7bab4dd6fa9d";
    fsType = "btrfs";
    options = [ "defaults" "noatime" "compress=zstd" "discard=async" "space_cache=v2" "nofail" ];
  };

  # Game stream host for Moonlight clients (e.g. legion). Uses AMD VAAPI/VCN
  # hardware encoding via the libva stack configured above.
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # required for KMS screen capture under Plasma Wayland
    openFirewall = true;
  };

  system.stateVersion = "26.05";
}
