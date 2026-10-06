# Home Manager config for the home server (omega) — CLI only.
{ ... }:
{
  imports = [
    ../common/base.nix
    ../common/packages.nix
    ../programs/git.nix
    ../programs/starship.nix
    ../programs/fzf.nix
    ../programs/fish.nix
    ../programs/tmux.nix
    ../programs/home-manager.nix
  ];

  home.stateVersion = "26.05";
}
