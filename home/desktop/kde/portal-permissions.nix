# Plasma "Remote control requested" prompt for legacy X11 input emulation.
#
# On the Plasma Wayland session, Steam Input's controller-as-mouse goes
# through XWayland, which forwards XTest input emulation to the RemoteDesktop
# portal — and xdg-desktop-portal-kde prompts every time because XWayland
# sends no app-id, so the decision can never be persisted (kde bug 502866).
# The fix is a permission-store entry with an empty app-id (all legacy X11
# apps); a runAlways script re-asserts it on every login.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.kdePortalPermissions;
  flatpak = lib.getExe' pkgs.flatpak "flatpak";
in
{
  options.programs.kdePortalPermissions.remoteDesktop = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Allow the RemoteDesktop portal without prompting — grants legacy X11
      apps (Steam Input controller-as-mouse, KDE Connect, legacy systray
      icons) keyboard/pointer control with no popup.
    '';
  };

  config = lib.mkIf cfg.remoteDesktop {
    programs.plasma.startup.startupScript."portal-permissions" = {
      runAlways = true;
      priority = 6;
      text = ''
        ${flatpak} permission-set kde-authorized remote-desktop "" yes || true
      '';
    };
  };
}
