# citadel — AMD desktop (CPU + GPU), SteamOS-like experience via Jovian.
{
  lib,
  pkgs,
  hostname,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/jovian.nix
    ../../modules/gaming.nix
    ../../modules/btrfs-tuning.nix
  ];

  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    # On the default kernel (see modules/common.nix), NOT
    # pkgs.cachyosKernels.linuxPackages-cachyos-rc: that RC kernel's out-of-tree
    # amdgpu DC patchset (for HDMI 2.1 VRR/FRL) causes a hang on every
    # shutdown/reboot, confirmed by bisecting it out. See README/CLAUDE.md.
    # Test: CachyOS's RC kernel only changes the *default value* of the existing
    # amdgpu_dc_feature_mask module param (2 -> 0x402) to get HDMI FRL/VRR — the
    # feature itself may already be in mainline, just gated off. Try it here first.
    kernelParams = [ "amdgpu.dc_feature_mask=0x402" ];
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
  };

  console.keyMap = "br-abnt2";

  networking.hostName = hostname;

  services = {
    # Kept from the desktop session for use while "Exit to Desktop"'d out of gamescope.
    hardware.openrgb.enable = true;

    xserver.xkb = lib.mkDefault {
      layout = "br";
      variant = "abnt2";
    };
  };

  system.stateVersion = "26.05";
}
