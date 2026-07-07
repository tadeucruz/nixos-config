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

  # InputPlumber bundles its own udev rules/hwdb (e.g. 99-inputplumber-device-setup.rules),
  # which re-apply the hid-lenovo-go sysfs quirks (os_mode=linux, imu_bypass_enable,
  # touchpad/vibration_enable) on every add/change/bind of the controller's HID
  # interfaces. RPM/pacman packaging installs these automatically; Nix does not
  # wire a package's bundled udev rules in on its own. Without this, the Legion Go
  # never leaves its default firmware mode and InputPlumber's CompositeDevice ends
  # up empty until manually restarted.
  services.udev.packages = [ pkgs.inputplumber ];

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