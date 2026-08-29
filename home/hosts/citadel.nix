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
    ../common/base.nix
    ../common/packages.nix
    ../common/unstable.nix
    ../common/linux.nix
    ../programs/firefox.nix
    ../programs/git.nix
    ../programs/starship.nix
    ../programs/fzf.nix
    ../programs/zsh.nix
    ../programs/home-manager.nix
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
