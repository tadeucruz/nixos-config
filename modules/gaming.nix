# Shared gaming stack (citadel + prothean + legion). Gamescope/session integration
# is handled separately by Jovian on citadel and legion; this covers the
# generic Steam features useful everywhere.
{ ... }:
{
  hardware = {
    steam-hardware.enable = true;
    xpadneo.enable = true;
  };

  programs = {
    gamemode.enable = true;

    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
      remotePlay.openFirewall = true;
    };
  };
}
