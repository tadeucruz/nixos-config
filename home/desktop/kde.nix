{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  programs.plasma = {
    enable = true;

    # Fully declarative: plasma-manager owns the config and resets anything not
    # declared here back to the Plasma default on rebuild (the GUI can't win) —
    # the same model as the GNOME dconf config. Applied identically on every
    # host that imports modules/desktop/kde.nix.
    overrideConfig = true;

    # Dark mode as the default.
    workspace.lookAndFeel = "org.kde.breezedark.desktop";

    powerdevil = {
      AC.powerProfile = "balanced";
      battery.powerProfile = "powerSaving";
      lowBattery.powerProfile = "powerSaving";
    };

    # Default panel layout, with a fixed set of pinned launchers on the Icon
    # Tasks widget (the same useful apps that were on GNOME's dash, mapped to
    # their KDE equivalents). `applications:` URIs are stable — unlike the
    # file:///nix/store/... paths Plasma saves when you pin via the GUI, which
    # break once that store path is GC'd. Declaring `panels` replaces the
    # existing panel(s) on activation.
    panels = [
      {
        location = "bottom";
        floating = true;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            iconTasks = {
              launchers = [
                "applications:firefox.desktop"
                "applications:md.obsidian.Obsidian.desktop"
                "applications:org.kde.konsole.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:systemsettings.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
  };

  home.activation.rebuildKdeSycoca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.getExe' pkgs.kdePackages.kservice "kbuildsycoca6"} --noincremental || true
  '';
}
