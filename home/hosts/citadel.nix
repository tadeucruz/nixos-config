{ pkgs, ... }:
let
  # Written to both the applications dir (via xdg.desktopEntries) and the
  # Desktop (via home.file). The Desktop symlink used to be manual and pointed
  # into an old home-manager generation that GC removed -> broken shortcut.
  return-to-steam-desktop = pkgs.writeText "return-to-steam.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Return to Steam
    Comment=Switch back to Steam Big Picture session
    Exec=start-gamescope-session
    Icon=steam
    Terminal=false
    Categories=Game;
  '';
in
{
  imports = [
    ../common/all.nix
    ../common/linux.nix
    ../gaming.nix
  ];

  home.sessionVariables = {
    DXVK_FRAME_RATE = "120";
    SteamDeck = "0";
  };

  home.file = {
    # Managed by home-manager in both spots so the Desktop symlink survives GC
    # (a manual ~/Desktop symlink used to point into an old generation).
    ".local/share/applications/return-to-steam.desktop".source = return-to-steam-desktop;
    "Desktop/return-to-steam.desktop" = {
      source = return-to-steam-desktop;
      force = true;
    };
  };
}
