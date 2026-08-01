# Full desktop environment (used on citadel and g15).
{ pkgs, lib, ... }:
{
  services = {
    desktopManager.plasma6.enable = true;

    displayManager.plasma-login-manager.enable = true;

    hardware.openrgb.enable = true;

    printing.enable = true;

    xserver.xkb = lib.mkDefault {
      layout = "us";
      variant = "intl";
    };
  };
}
