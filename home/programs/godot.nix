# Godot 4 game engine (Linux only — cached for x86_64-linux).
# macOS uses the Homebrew cask (homebrew/development.nix): nixpkgs' godot_4 has
# no aarch64-darwin substitute, and its harfbuzz checkPhase fails on macOS 27.
{ pkgs, ... }:
{
  home.packages = [ pkgs.godot_4 ];
}
