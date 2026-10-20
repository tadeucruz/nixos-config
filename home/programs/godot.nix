# Godot 4 game engine — no home-manager module, package wrapper only.
{ pkgs, ... }:
{
  # TODO(temp): godot_4 (4.7+) is broken in the current nixpkgs; pinned to 4.6.
  # Switch back to pkgs.godot_4 once it builds again.
  home.packages = [ pkgs.godot_4_6 ];
}
