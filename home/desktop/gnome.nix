# GNOME home bits — wired by modules/desktop/gnome.nix.
{ ... }:
{
  dconf.settings = {
    "org/gnome/shell" = {
      # GNOME has no native system tray: the AppIndicator extension (installed
      # system-wide by modules/desktop/gnome.nix) renders StatusNotifier items,
      # and dconf turns it on for this user. Note this list is declarative —
      # extensions enabled later via the Extensions app get reverted on rebuild.
      disable-user-extensions = false;
      enabled-extensions = [ "appindicatorsupport@rgcjonas.gmail.com" ];

      # Dash favorites — desktop ids verified against the prothean profiles
      # (/run/current-system/sw + /etc/profiles/per-user).
      favorite-apps = [
        "firefox.desktop"
        "code.desktop"
        "md.obsidian.Obsidian.desktop"
        "org.gnome.Console.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Settings.desktop"
      ];
    };

    # Interface: dark scheme (matches Dracula terminal/prompt), detailed
    # clock, and no hot corner (Super already opens the overview).
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-show-date = true;
      clock-show-weekday = true;
      enable-hot-corners = false;
    };

    # Touchpad: tap-to-click and two-finger scrolling — both schema defaults,
    # declared explicitly so they survive dconf resets.
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };
  };
}
