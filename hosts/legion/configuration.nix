# legion — Legion Go (APU AMD Z1 Extreme). Handheld.
{
  config,
  pkgs,
  lib,
  username,
  hostname,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/gaming.nix
    ../../modules/jovian.nix
    ../../modules/btrfs-tuning.nix
  ];

  boot = {
    kernelModules = [
      "hid_lenovo_go"
      "uhid"
      "uinput"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  networking.hostName = hostname;

  # Nix doesn't wire a package's bundled udev rules in automatically like RPM/pacman
  # do; without this the hid-lenovo-go quirks never apply and InputPlumber sees no controller.
  services.udev.packages = [ pkgs.inputplumber ];

  system.stateVersion = "26.05";
}
