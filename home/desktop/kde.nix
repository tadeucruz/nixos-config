{
  pkgs,
  lib,
  inputs,
  username,
  ...
}:
let
  # Folder synced from the hub — see modules/services/syncthing.nix.
  wallpapers = "/home/${username}/Pictures/Wallpapers";
  slideInterval = 1800; # seconds between slides
in
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

    # Rotate the desktop wallpaper on every screen. Not keyed by monitor name
    # or index: plasma-manager's script loops over all desktops (containments),
    # so this follows whatever screens exist.
    workspace.wallpaperSlideShow = {
      path = wallpapers;
      interval = slideInterval;
    };
    workspace.wallpaperFillMode = "preserveAspectCrop";

    # plasma-manager desktop scripts run only once (tracked by content hash), so
    # a monitor plugged in later would sit on Plasma's default wallpaper. Re-apply
    # on every login so any screen converges, including ones added afterwards.
    startup.desktopScript."wallpaper_all_screens" = {
      priority = 4; # after plasma-manager's own wallpaper script (priority 3)
      runAlways = true;
      # NOTE: this is JavaScript, not Nix — comments are // (a # would be a
      # syntax error). Mirrors plasma-manager's own slideshow script.
      text = ''
        var allDesktops = desktops();
        for (var i = 0; i < allDesktops.length; i++) {
            var desktop = allDesktops[i];
            desktop.wallpaperPlugin = "org.kde.slideshow";
            desktop.currentConfigGroup = Array("Wallpaper", "org.kde.slideshow", "General");
            desktop.writeConfig("SlidePaths", "${wallpapers}");
            desktop.writeConfig("SlideInterval", "${toString slideInterval}");
            desktop.writeConfig("FillMode", "2"); // preserveAspectCrop
        }
      '';
    };

    # Same folder on the lockscreen. kscreenlockerrc is global, not per-screen.
    kscreenlocker.appearance.wallpaperSlideShow = {
      path = wallpapers;
      interval = slideInterval;
    };

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
