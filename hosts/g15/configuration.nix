# g15 — Dell G15 5525: AMD Ryzen 6800H (iGPU Radeon 680M) + Nvidia dGPU. Laptop.
{ config, pkgs, lib, inputs, username, hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/desktop.nix
    ../../modules/gaming.nix
    inputs.awcc.nixosModules.default
  ];

  networking.hostName = hostname;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Required by AWCC for fan/thermal control on Alienware/Dell G-series.
  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  services.awcc.enable = true;

  # --- Hybrid GPU: Radeon 680M (iGPU) + Nvidia (dGPU) ---
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true; 

    powerManagement.enable = true;
    powerManagement.finegrained = true; # powers off dGPU when idle (saves battery)

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # enables `nvidia-offload <app>` helper command
      };
      # >>> REPLACE with real bus IDs from this machine <<<
      # Run:  lspci | grep -E 'VGA|3D'
      # Convert address (e.g. 06:00.0 -> "PCI:6:0:0").
      amdgpuBusId = "PCI:116:0:0"; # iGPU Radeon
      nvidiaBusId = "PCI:1:0:0"; # dGPU Nvidia
    };
  };

  system.stateVersion = "26.05";
}
