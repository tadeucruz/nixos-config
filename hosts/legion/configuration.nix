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
    ../../modules/common/linux.nix
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

  # MT7921e (Legion Go's WiFi) drops/stalls association with power save on —
  # observed 2026-08-26: repeated "association took too long" until it connects.
  # wifi.powersave = 2 disables it (NetworkManager config).
  networking.networkmanager.wifi.powersave = false;

  # Testing InputPlumber again (Bazzite 44 moved to it). HHD was the previous
  # path; commit a20ef09 was the migration. power-profiles-daemon and decky stay
  # disabled either way (ppd fights TDP, decky plugins now redundant/optional).
  services.inputplumber.enable = true;

  # InputPlumber needs its udev rules so it sees the Legion Go controllers.
  services.udev.packages = [ pkgs.inputplumber ];

  services.power-profiles-daemon.enable = lib.mkForce false;

  jovian.decky-loader.enable = lib.mkForce false;

  system.stateVersion = "26.05";
}
