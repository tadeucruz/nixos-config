# Home Manager config for the MacBook (normandy).
{ ... }:
{
  imports = [
    ../common/base.nix
    ../common/packages.nix
    ../common/darwin.nix
    ../programs/firefox.nix
    ../programs/git.nix
    ../programs/starship.nix
    ../programs/fzf.nix
    ../programs/zsh.nix
    ../programs/tmux.nix
    ../programs/home-manager.nix
    ../development.nix
    ../ai.nix
    ../programs/neovim.nix
  ];

  home.stateVersion = "26.11";
}
