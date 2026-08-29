# Home Manager config for the MacBook (normandy).
{ ... }:
{
  imports = [
    ../common/base.nix
    ../common/packages.nix
    ../common/unstable.nix
    ../common/darwin.nix
    ../programs/firefox.nix
    ../programs/git.nix
    ../programs/starship.nix
    ../programs/fzf.nix
    ../programs/zsh.nix
    ../programs/home-manager.nix
    ../development.nix
    ../programs/neovim.nix
  ];
}
