{ ... }:
{
  imports = [
    ./base.nix
    ./packages.nix
    ./unstable.nix
    ../programs/firefox.nix
    ../programs/git.nix
    ../programs/starship.nix
    ../programs/fzf.nix
    ../programs/zsh.nix
    ../programs/home-manager.nix
  ];
}
