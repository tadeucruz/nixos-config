# Full desktop environment (used on citadel and g15).
{ config, pkgs, lib, username, ... }:
{
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;

  services.xserver.xkb = lib.mkDefault {
    layout = "us";
    variant = "intl";
  };

  services.printing.enable = true;

  # RGB lighting control (motherboard/peripherals); auto-detects AMD i2c support
  # from hardware.cpu.amd.updateMicrocode set in each host's hardware-configuration.nix.
  services.hardware.openrgb.enable = true;

  services.syncthing = {
    enable = true;
    user = username;
    dataDir = "/home/${username}";
  };

  nixpkgs.config.permittedInsecurePackages = [ "electron-39.8.10" ];

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
  ];
}
