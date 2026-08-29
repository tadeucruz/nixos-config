# Home Manager config for the MacBook (normandy).
{ ... }:
{
  imports = [
    ../common/all.nix
    ../common/darwin.nix
    ../development.nix
    ../programs/neovim.nix
  ];
}
