{
  lib,
  inputs,
  username,
  ...
}:
{
  imports = [ inputs.laminix.nixosModules.default ];

  options.desktop.sessionName = lib.mkOption {
    type = lib.types.str;
    description = "Session name used by the desktop environment (e.g. the Jovian/gamescope fallback session).";
  };

  config = {
    desktop.sessionName = "plasma";

    environment.laminix.enable = true;

    services = {
      desktopManager.plasma6.enable = true;
      displayManager.plasma-login-manager.enable = lib.mkDefault true;
    };

    programs.kde-pim.enable = false;

    # Electron apps (VSCode etc.) run on native Wayland instead of XWayland
    # under Plasma's Wayland session.
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    home-manager.users.${username}.imports = [ ../../home/desktop/kde.nix ];
  };
}
