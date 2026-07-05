# legion — Legion Go (APU AMD Z1 Extreme). Handheld.
{ config, pkgs, lib, username, hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/jovian.nix
  ];

  networking.hostName = hostname;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "uinput" "uhid" "hid_lenovo_go" ];

  # --- APU AMD (Z1 Extreme) ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Legion Go-specific decky-loader plugin: https://github.com/aarron-lee/LegionGoRemapper
  jovian.decky-loader.extraPackages = with pkgs; [ hidapi ];
  systemd.services.decky-loader.environment.LD_LIBRARY_PATH = "${pkgs.hidapi}/lib";

  # hid_lenovo_go rebinds HID interfaces at boot before the session is active,
  # so logind's uaccess never applies. Static GROUP bypasses the race condition.
  services.udev.extraRules = ''
    KERNEL=="hidraw*", KERNELS=="0003:28DE:12FE.*", MODE="0660", GROUP="input"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="17ef", TAG+="uaccess", MODE="0666"
  '';

  # InputPlumber starts before hid_lenovo_go's boot-time HID rebind settles,
  # so it can grab the Legion Go's evdev/hidraw nodes mid-flux and end up with
  # an empty CompositeDevice (no gamepad) until manually restarted.
  systemd.services.inputplumber = {
    after = [ "systemd-udevd.service" ];
    wants = [ "systemd-udevd.service" ];
  };

  system.stateVersion = "26.05";
}