# Shared Home Manager config for development tools (prothean + normandy).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    claude-code
    go
    godot_4
    jdk
    nodejs
    opencode
    vscode
  ];
}
