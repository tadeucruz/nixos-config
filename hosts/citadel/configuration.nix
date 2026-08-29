# citadel — AMD desktop (CPU + GPU), SteamOS-like experience via Jovian.
{
  config,
  lib,
  pkgs,
  hostname,
  ...
}:
let
  # gamescope-session starts gamescope without --hdr-enabled, so HDR content is
  # tonemapped to SDR and washed out on an HDR display. This shim (prepended to
  # PATH via the Jovian pre-start hook) injects the flag before the real
  # cap_sys_nice wrapper. Must be named "gamescope" so the session finds it.
  gamescope-hdr-shim = pkgs.writeShellScriptBin "gamescope" ''
    exec /run/wrappers/bin/gamescope --hdr-enabled "$@"
  '';
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common/linux.nix
    ../../modules/jovian.nix
    ../../modules/gaming.nix
    ../../modules/btrfs-tuning.nix
  ];

  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    # OpenGamingCollective kernel: linux_latest + OGC monolithic.patch
    # (AMD HDMI 2.1 VRR/ALLM, not in vanilla).
    kernelPackages = import ../../modules/ogc-kernel.nix { inherit pkgs lib; };
    kernelParams = [ "transparent_hugepage=always" ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
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

  environment.systemPackages = [ pkgs.ethtool ];

  console.keyMap = "br-abnt2";

  environment.etc."jovian/gamescope-session/pre-start".text = ''
    export PATH=${gamescope-hdr-shim}/bin:$PATH
  '';

  networking.hostName = hostname;

  # Desktop gaming, always on AC power: force max CPU boost (amd_pstate EPP
  # follows and becomes "performance"). Keeps lowest latency/consistency.
  powerManagement.cpuFreqGovernor = "performance";

  services = {
    # Kept from the desktop session for use while "Exit to Desktop"'d out of gamescope.
    hardware.openrgb.enable = true;

    xserver.xkb = lib.mkDefault {
      layout = "br";
      variant = "abnt2";
    };
  };

  # Turn off all RGB lighting at boot (ASRock motherboard via OpenRGB). The
  # devices default to their factory rainbow loop; apply mode "off" once the
  # udev rules from hardware.openrgb are live.
  systemd.services.openrgb-off = {
    description = "Turn off all OpenRGB devices";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.openrgb} -m off --noautoconnect";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  # Wake-on-LAN for the Realtek RTL8125 (enp10s0). The r8169 driver persists
  # the setting across shutdown, so enabling it once at boot is enough.
  systemd.services.enable-wol = {
    description = "Enable Wake-on-LAN on enp10s0";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-pre.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.ethtool} -s enp10s0 wol g";
      RemainAfterExit = true;
    };
  };

  system.stateVersion = "26.05";
}
