# CLI-only Home Manager config for headless servers (omega): no firefox/KDE.
{ ... }:
{
  imports = [
    ./base.nix
    ./packages.nix
    ./git.nix
    ./starship.nix
    ./fzf.nix
    ./zsh.nix
    ./home-manager.nix
  ];
}
