# prothean (Dell G15 5525): AMD Ryzen 6800H (iGPU Radeon 680M) + Nvidia dGPU. Laptop.
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
    ../../modules/common.nix
    ../../modules/desktop.nix
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

    logind.settings.Login.HandleLidSwitchExternalPower = "ignore"; # stays reachable over Tailscale when parked on AC (e.g. left at parents' house)

    xserver = {
      videoDrivers = [ "nvidia" ];
      xkb = {
        layout = "br";
        variant = "";
      };
    };
  };

  system.stateVersion = "26.05";
}
