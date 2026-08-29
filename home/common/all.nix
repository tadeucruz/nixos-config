# Shared Home Manager config across all machines (cross-platform).
{ ... }:
{
  imports = [
    ./base.nix
    ./packages.nix
    ./unstable.nix
    ./firefox.nix
    ./git.nix
    ./starship.nix
    ./fzf.nix
    ./zsh.nix
    ./home-manager.nix
  ];
}
