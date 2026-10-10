{
  lib,
  username,
  ...
}:
{
  options.desktop.sessionName = lib.mkOption {
    type = lib.types.str;
    description = "Session name used by the desktop environment (e.g. the Jovian/gamescope fallback session).";
  };

  config = {
    desktop.sessionName = "plasma";

    services = {
      desktopManager.plasma6.enable = true;
      displayManager.plasma-login-manager.enable = lib.mkDefault true;
    };

    programs.kde-pim.enable = false;

    home-manager.users.${username}.imports = [ ../../home/desktop/kde.nix ];
  };
}
