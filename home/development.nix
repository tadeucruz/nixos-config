# Shared Home Manager config for development tools (citadel + prothean).
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
