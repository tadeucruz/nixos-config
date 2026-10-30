# GNOME desktop stack — imported by prothean.
# Drop-in replacement for modules/desktop/kde.nix (imported by citadel/legion):
# import one or the other per host, never both (they fight over the display
# manager and both declare options.desktop.sessionName).
{
  lib,
  pkgs,
  username,
  ...
}:
{
  options.desktop.sessionName = lib.mkOption {
    type = lib.types.str;
    description = "Session name used by the desktop environment (e.g. the Jovian/gamescope fallback session).";
  };

  config = {
    desktop.sessionName = "gnome";

    services = {
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = lib.mkDefault true;

      # Intentionally no services.xserver.enable: GNOME 50 + GDM are
      # Wayland-only (nixpkgs even removed the gdm.wayland option) and the
      # current NixOS wiki's minimal GNOME config doesn't set it either.
      # Xwayland — still needed by Steam/Proton apps — ships with the
      # session, not with the Xorg stack.
      gnome.games.enable = false;
    };

    programs.dconf.enable = true;

    environment = {
      # Electron apps (VSCode etc.) run on native Wayland instead of XWayland
      # under GNOME's Wayland session.
      sessionVariables.NIXOS_OZONE_WL = "1";

      # GNOME has no native system tray — this extension provides it (enabled
      # per-user via dconf in home/desktop/gnome.nix).
      systemPackages = [ pkgs.gnomeExtensions.appindicator ];
    };

    home-manager.users.${username}.imports = [ ../../home/desktop/gnome.nix ];
  };
}
