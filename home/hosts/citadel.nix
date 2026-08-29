{ pkgs, ... }:
let
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
    ".local/share/applications/return-to-steam.desktop".source = return-to-steam-desktop;
    "Desktop/return-to-steam.desktop" = {
      source = return-to-steam-desktop;
      force = true;
    };
  };
}
