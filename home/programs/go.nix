# Go toolchain — no home-manager module, package wrapper only.
{ pkgs, ... }:
{
  home.packages = [ pkgs.go ];
}
