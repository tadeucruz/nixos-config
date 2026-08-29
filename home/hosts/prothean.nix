{ pkgs, ... }:
{
  imports = [
    ../common/all.nix
    ../common/linux.nix
    ../development.nix
    ../programs/neovim.nix
    ../gaming.nix
  ];

  home.packages = with pkgs; [ flutter ];

  home.sessionVariables = {
    PROTON_ENABLE_WAYLAND = "1";
    SteamDeck = "0";
  };
}
