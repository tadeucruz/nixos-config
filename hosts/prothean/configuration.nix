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
    ../../modules/common/locale.nix
    ../../modules/common/zsh.nix
    ../../modules/common/zram.nix
    ../../modules/boot/base.nix
    ../../modules/boot/gaming.nix
    ../../modules/users/base.nix
    ../../modules/users/gaming.nix
    ../../modules/networking/networkmanager.nix
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
    inputs.awcc.nixosModules.default
  ];

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
    kernelModules = [ "acpi_call" ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  console.keyMap = "br-abnt2";

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

    logind.settings.Login.HandleLidSwitchExternalPower = "ignore"; # stays reachable over Tailscale when parked on AC (e.g. left at parents' house)

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
