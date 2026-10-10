# GNOME home bits — wired by modules/desktop/gnome.nix.
{ ... }:
{
  # GNOME has no native system tray: the AppIndicator extension (installed
  # system-wide by modules/desktop/gnome.nix) renders StatusNotifier items,
  # and dconf turns it on for this user. Note this list is declarative —
  # extensions enabled later via the Extensions app get reverted on rebuild.
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [ "appindicatorsupport@rgcjonas.gmail.com" ];
    };
  };
}
