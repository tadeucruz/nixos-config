# Home Manager config for the home server (omega) — CLI only.
{ ... }:
{
  imports = [
    ../common/base.nix
    ../common/packages.nix
    ../programs/git.nix
    ../programs/starship.nix
    ../programs/fzf.nix
    ../programs/zsh.nix
    ../programs/home-manager.nix
  ];
}
