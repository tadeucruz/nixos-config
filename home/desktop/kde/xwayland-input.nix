# KWin's XWayland input-emulation prompt ("steam is asking to control
# input devices").
#
# On Plasma 6.8 X11 input emulation goes through libei, and KWin's
# eisprompter asks on every request because X11 apps can claim any
# WM_CLASS. The "Always allow apps claiming to be <app>" checkbox writes
# XwaylandEisNoPromptApps to kwinrc — re-asserted here by a systemd user
# service on every login, so it lands before kwin even starts. Written via
# kwriteconfig instead of plasma-manager because owning kwinrc would wipe
# GUI-set keys (overrideConfig) like Xwayland.Scale.
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
