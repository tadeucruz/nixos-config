# Shared Home Manager config for development tools (citadel + g15).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    claude-code
    go
    jdk
    vscode
  ];
}
