# Shared Home Manager config for development tools (prothean + normandy).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    claude-code
    flutter
    go
    godot_4
    jdk
    opencode
    vscode
  ];
}
