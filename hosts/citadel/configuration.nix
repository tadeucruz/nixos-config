{
  config,
  lib,
  pkgs,
  hostname,
  ...
}:
let
  gamescope-hdr-shim = pkgs.writeShellScriptBin "gamescope" ''
    exec /run/wrappers/bin/gamescope --hdr-enabled "$@"
  '';
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common/all.nix
    ../../modules/common/nix.nix
    ../../modules/common/ghostty.nix
    ../../modules/common/locale.nix
    ../../modules/common/zsh.nix
    ../../modules/common/zram.nix
    ../../modules/boot/base.nix
    ../../modules/boot/eac-kexec.nix
    ../../modules/boot/eac-iommu.nix
    ../../modules/boot/gaming.nix
    ../../modules/security/tpm2.nix
    ../../modules/users/base.nix
    ../../modules/users/gaming.nix
    ../../modules/networking/networkmanager.nix
    ../../modules/networking/firewall.nix
    ../../modules/networking/dns.nix
    ../../modules/desktop/fonts.nix
    ../../modules/desktop/bluetooth.nix
    ../../modules/desktop/rtkit.nix
    ../../modules/desktop/rocm.nix
    ../../modules/desktop/kde.nix
    ../../modules/services/avahi.nix
    ../../modules/services/flatpak.nix
    ../../modules/services/fwupd.nix
    ../../modules/services/openssh.nix
    ../../modules/services/pipewire.nix
    ../../modules/services/syncthing.nix
    ../../modules/services/tailscale.nix
    ../../modules/jovian.nix
    ../../modules/gaming.nix
    ../../modules/btrfs-tuning.nix
    ../../modules/storage-health.nix
  ];

  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    kernelPackages = import ../../modules/ogc-kernel.nix { inherit pkgs lib; };
    kernelParams = [
      "transparent_hugepage=always"
      "amdgpu.dcfeaturemask=0x402"
    ];
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

  # Extra env for the Steam session (base lives in modules/jovian.nix).
  # SteamDeck=0 stops games from hiding desktop graphics options; the frame cap
  # matches the 120 Hz output.
  jovian.steam.environment = {
    SteamDeck = "0";
    DXVK_FRAME_RATE = "120";
  };

  environment.etc."jovian/gamescope-session/pre-start".text = ''
    export PATH=${gamescope-hdr-shim}/bin:$PATH
  '';

  networking.hostName = hostname;

  powerManagement.cpuFreqGovernor = "performance";

  services = {
    hardware.openrgb.enable = true;

    xserver.xkb = lib.mkDefault {
      layout = "br";
      variant = "abnt2";
    };
  };

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
