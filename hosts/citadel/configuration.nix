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
    # Test: NOT pkgs.cachyosKernels.linuxPackages-cachyos-rc (that RC kernel's
    # out-of-tree amdgpu DC patchset hangs on every shutdown/reboot, confirmed by
    # bisecting it out — see README/CLAUDE.md). CachyOS's RC kernel only changes
    # the *default value* of the existing amdgpu_dc_feature_mask module param
    # (2 -> 0x402) to get HDMI FRL/VRR, rather than adding new code — so trying
    # mainline's own linuxPackages_testing (7.2-rc6, same base CachyOS forks from)
    # with that same flag, to see if VRR works without the RC kernel's patchset.
    kernelPackages = pkgs.linuxPackages_testing;
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
