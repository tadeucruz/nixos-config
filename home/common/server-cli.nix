# CLI-only Home Manager config for headless servers (omega): no firefox/KDE.
{ ... }:
{
  imports = [
    ./base.nix
    ./packages.nix
    ../programs/git.nix
    ../programs/starship.nix
    ../programs/fzf.nix
    ../programs/zsh.nix
    ../programs/home-manager.nix
  ];
}
