# Nix language server — used by Zed's Nix extension.
{ pkgs, ... }:
{
  home.packages = [ pkgs.nixd ];
}
