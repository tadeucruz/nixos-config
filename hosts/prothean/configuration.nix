{
  config,
  pkgs,
  lib,
  inputs,
  username,
  hostname,
  ...
}:
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
    ../../modules/networking/ipv6.nix
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
    ../../modules/gaming.nix
    ../../modules/btrfs-tuning.nix
    ../../modules/storage-health.nix
    # ./stay-awake-ac.nix
    inputs.awcc.nixosModules.default
  ];

  boot = {
    extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
    kernelModules = [ "acpi_call" ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  console.keyMap = "br-abnt2";

  # Gaming env for the KDE session. Steam is autostarted from that session, which
  # comes from PAM, so `environment.sessionVariables` (/etc/environment) reaches
  # it — unlike `home.sessionVariables`, which Steam never sees.
  environment.sessionVariables = {
    PROTON_FSR4_UPGRADE = "1";
    PROTON_FSR4_RDNA3_UPGRADE = "1";
    PROTON_USE_NTSYNC = "1";
    PROTON_ENABLE_WAYLAND = "1";
    SteamDeck = "0";
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;

      powerManagement.enable = true;
      powerManagement.finegrained = true; # powers off dGPU when idle (saves battery)

      prime = {
        amdgpuBusId = "PCI:116:0:0";
        nvidiaBusId = "PCI:1:0:0";

        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };
  };

  networking.hostName = hostname;

  services = {
    awcc.enable = true;

    hardware.openrgb.enable = true;

    printing.enable = true;

    xserver = {
      videoDrivers = [ "nvidia" ];
      xkb = {
        layout = "br";
        variant = "";
      };
    };
  };

  systemd.services.awccd.path = [
    "/run/wrappers"
    pkgs.polkit
  ];

  system.stateVersion = "26.05";
}
