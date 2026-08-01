{ ... }:
{
  imports = [
    ./common.nix
    ./development.nix
    ./gaming.nix
  ];

  # Proton on Wayland; force off Steam Deck identification since this is a real desktop.
  home.sessionVariables = {
    PROTON_ENABLE_WAYLAND = "1";
    DXVK_FRAME_RATE = "155";
    SteamDeck = "0";
  };
}
