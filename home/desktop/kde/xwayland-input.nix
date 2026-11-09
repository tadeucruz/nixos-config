# KWin's XWayland input prompt ("steam is asking to control input devices").
# Re-asserted by a systemd user service so it lands before kwin starts; use
# kwriteconfig, not plasma-manager — owning kwinrc would wipe GUI keys (overrideConfig).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.kdeXwaylandInput;
  kwriteconfig = lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6";
in
{
  options.programs.kdeXwaylandInput.noPromptApps = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [ "steam" ];
    description = ''
      X11 apps (by WM_CLASS claim) allowed to emulate pointer/keyboard input
      without KWin's "Remote Control" prompt (kwinrc Xwayland.XwaylandEisNoPromptApps).
    '';
  };

  config = lib.mkIf (cfg.noPromptApps != [ ]) {
    systemd.user.services.kde-xwayland-input = {
      Unit.Description = "Allow claimed X11 apps to emulate input without the KWin prompt";
      Service = {
        Type = "oneshot";
        ExecStart = lib.concatStringsSep " " [
          kwriteconfig
          "--file kwinrc"
          "--group Xwayland"
          "--key XwaylandEisNoPromptApps"
          ''"${lib.concatStringsSep "," cfg.noPromptApps}"''
        ];
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
