# Obsidian notes — no home-manager module, package wrapper only.
{ pkgs, ... }:
{
  home.packages = [ pkgs.obsidian ];
}
