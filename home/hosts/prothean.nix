{ pkgs, ... }:
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
    ../programs/opencode.nix
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
