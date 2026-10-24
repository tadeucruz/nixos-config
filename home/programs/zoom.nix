# Zoom client — no home-manager module, package wrapper only (`zoom.us.app`).
{ pkgs, ... }:
{
  home.packages = [ pkgs.zoom-us ];
}
