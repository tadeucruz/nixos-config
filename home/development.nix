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
