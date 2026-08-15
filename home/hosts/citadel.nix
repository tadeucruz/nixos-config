{ ... }:
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

  xdg.desktopEntries.return-to-steam = {
    name = "Return to Steam";
    comment = "Switch back to Steam Big Picture session";
    exec = "start-gamescope-session";
    icon = "steam";
    terminal = false;
    categories = [ "Game" ];
  };
}
