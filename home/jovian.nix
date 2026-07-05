# Shared Home Manager config for Jovian machines (htpc + legion).
{ ... }:
{
  xdg.desktopEntries.return-to-steam = {
    name = "Return to Steam";
    comment = "Switch back to Steam Big Picture session";
    exec = "steamos-session-select steam";
    icon = "steam";
    terminal = false;
    categories = [ "Game" ];
  };
}
