{ pkgs, ... }:
{
  imports = [
    ../common/all.nix
    ../common/linux.nix
    ../development.nix
    ../gaming.nix
  ];

  # flutter is a Homebrew cask on normandy; keep it from nixpkgs here on Linux.
  home.packages = with pkgs; [ flutter ];

  # Proton on Wayland; force off Steam Deck identification since this is a real desktop.
  home.sessionVariables = {
    PROTON_ENABLE_WAYLAND = "1";
    SteamDeck = "0";
  };
}
