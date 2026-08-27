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
    # uhid/uinput are needed by Handheld Daemon's controller emulation.
    # hid-lenovo-go is blacklisted: HHD reads the Legion Go controllers raw via
    # hidraw/evdev, and the kernel driver fights its emulation (controllers
    # plug/unplug in gamescope). Same approach as anatase/CachyOS.
    blacklistedKernelModules = [ "hid-lenovo-go" ];
    kernelModules = [
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

  # Handheld Daemon replaces InputPlumber + Decky on the Legion Go. It covers
  # everything the Decky plugins did: controller emulation (incl. joystick-as-
  # mouse in KDE), back buttons/remap, RGB, and TDP + fan curves (adjustor).
  #
  # Migration from InputPlumber+Decky → HHD. Rollback point: commit 21f38dd
  # ("legion: disable wifi power save") if anything regresses.
  services.handheld-daemon = {
    enable = true;
    user = username;
    ui.enable = true;
    adjustor = {
      enable = true;
      # TDP on the Legion Go goes through acpi_call (Lenovo WMI methods).
      loadAcpiCallModule = true;
    };
  };

  # HHD and InputPlumber fight over the raw controllers — HHD can't see the
  # devices. The jovian steam module enables inputplumber without mkDefault, so
  # mkForce is required to win.
  services.inputplumber.enable = lib.mkForce false;

  # power-profiles-daemon fights adjustor over the power profile, silently
  # breaking TDP (documented HHD caveat). Disabled for the HHD path.
  services.power-profiles-daemon.enable = lib.mkForce false;

  # Decky was only kept for TDP (SimpleDeckyTDP), RGB and button remap
  # (LegionGoRemapper) — all provided by HHD now. Disabled only here; citadel
  # still uses decky-loader via modules/jovian.nix.
  jovian.decky-loader.enable = lib.mkForce false;

  system.stateVersion = "26.05";
}
