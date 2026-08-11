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
    # CachyOS RC kernel: carries the out-of-tree HDMI 2.1 VRR/FRL patchset that
    # still hasn't landed in mainline amdgpu (confirmed missing on linuxPackages_testing
    # 7.2.0-rc6 — no vrr_capable property on the HDMI connector at all; upstream is now
    # targeting the Linux 7.3 merge window, not guaranteed). Risk accepted.
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-rc;
    # Temporary: disable Plymouth splash to read the actual shutdown/reboot
    # hang message on screen (debugging the mobo-logo freeze on power cycle).
    consoleLogLevel = lib.mkForce 7;
    initrd.verbose = lib.mkForce true;
    plymouth.enable = lib.mkForce false;
    # Test fix: hang happens in device_shutdown() right after the network
    # driver's .shutdown() runs — likely amdgpu stuck in BACO runtime PM
    # during its own .shutdown() hook. Disable runtime PM to rule it out.
    kernelParams = lib.mkForce [ "amdgpu.runpm=0" ];
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
