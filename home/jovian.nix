# Shared Home Manager config for Jovian machines (htpc + legion).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    protonplus
  ];

  xdg.desktopEntries.return-to-steam = {
    name = "Return to Steam";
    comment = "Switch back to Steam Big Picture session";
    exec = "start-gamescope-session";
    icon = "steam";
    terminal = false;
    categories = [ "Game" ];
  };
}
