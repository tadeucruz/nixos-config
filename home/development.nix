# Shared Home Manager config for development tools (citadel + g15).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    claude-code
    go
    godot_4
    jdk
    vscode
  ];
}
