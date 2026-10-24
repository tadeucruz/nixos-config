# Element Desktop (Matrix client) — no home-manager module, package wrapper only.
{ pkgs, ... }:
{
  home.packages = [ pkgs.element-desktop ];
}
