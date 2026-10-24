# Rectangle window manager — no home-manager module, package wrapper only.
{ pkgs, ... }:
{
  home.packages = [ pkgs.rectangle ];
}
