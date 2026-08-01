# citadel — AMD desktop (CPU + GPU). Gaming PC, normal desktop like g15.
{
  config,
  pkgs,
  lib,
  username,
  hostname,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/desktop.nix
    ../../modules/gaming.nix
    ../../modules/btrfs-tuning.nix
  ];

  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  fileSystems."/GAMES" = {
    device = "/dev/disk/by-uuid/be622b96-26c5-4ff2-b740-7bab4dd6fa9d";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
      "discard=async"
      "noatime"
      "nofail"
      "space_cache=v2"
    ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  networking.hostName = hostname;

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # required for KMS screen capture under Plasma Wayland
    openFirewall = true;
    settings = {
      encoder = "vulkan";
      vk_rc_mode = 2; # CBR
      output_name = 1; # DP-1
    };
  };

  system.stateVersion = "26.05";
}
