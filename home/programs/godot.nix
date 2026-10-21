# Godot 4 game engine — no home-manager module, package wrapper only.
{ pkgs, ... }:
{
  home.packages = [ pkgs.godot_4 ];
}
