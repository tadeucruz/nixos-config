# Shared Home Manager config for development tools (citadel + g15).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vscode
    claude-code
  ];
}
