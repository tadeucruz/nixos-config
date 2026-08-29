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

    # Mask to prevent DrKonqi's unbounded crash-loop when it can't find a display (KDE bug 524048, unfixed): https://bugs.kde.org/show_bug.cgi?id=524048
    systemd.user.sockets."drkonqi-coredump-launcher".enable = false;

    home-manager.users.${username}.imports = [ ../../home/desktop/kde.nix ];
  };
}
