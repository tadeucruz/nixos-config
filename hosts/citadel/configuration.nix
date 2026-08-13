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
    # Built locally from AMD's amd-staging-drm-next branch with the official HDMI 2.1
    # VRR/ALLM patch series applied (posted upstream 2026-08-06, targeting Linux 7.4).
    # See hosts/citadel/kernel-amd-staging-vrr.nix.
    kernelPackages = import ./kernel-amd-staging-vrr.nix { inherit pkgs; };
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
