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

  # CachyOS handheld variant: BORE scheduler + Steam Deck/ROG Ally/MSI Claw
  # HID quirks, tuned for gaming handhelds like the Legion Go.
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-deckify;

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
    # SUBSYSTEMS=="usb", ATTRS{idVendor}=="17ef", TAG+="uaccess", MODE="0666"
  '';

  # InputPlumber starts before hid_lenovo_go's boot-time HID rebind settles,
  # so it can grab the Legion Go's evdev/hidraw nodes mid-flux and end up with
  # an empty CompositeDevice (no gamepad) until manually restarted.
  systemd.services.inputplumber = {
    after = [ "systemd-udevd.service" ];
    wants = [ "systemd-udevd.service" ];
  };

  # InputPlumber ships a joystick-to-mouse profile but nothing loads it
  # automatically — Jovian just runs it with the default (gamepad-only)
  # profile. Load mouse_keyboard_wasd.yaml when the KDE desktop session
  # starts (OnlyShowIn=KDE keeps this from firing inside the gamescope
  # session, where a real gamepad is wanted instead).
  environment.etc."xdg/autostart/inputplumber-desktop-profile.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=InputPlumber desktop mouse profile
    OnlyShowIn=KDE;
    Exec=${pkgs.systemd}/bin/busctl call org.shadowblip.InputPlumber /org/shadowblip/InputPlumber/CompositeDevice0 org.shadowblip.Input.CompositeDevice LoadProfilePath s ${pkgs.inputplumber}/share/inputplumber/profiles/mouse_keyboard_wasd.yaml
    X-KDE-autostart-phase=1
  '';

  # Tuning for the btrfs subvolumes defined in hardware-configuration.nix.
  # Kept here (not there) since that file gets overwritten by nixos-generate-config.
  # NixOS merges fileSystems.<mount>.options across modules, so this appends
  # to the existing options (e.g. subvol=home) instead of replacing them.
  fileSystems."/".options = [ "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];
  fileSystems."/home".options = [ "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];
  fileSystems."/nix".options = [ "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];

  # Periodic TRIM as a backup to discard=async on all btrfs mounts.
  services.fstrim.enable = true;

  system.stateVersion = "26.05";
}