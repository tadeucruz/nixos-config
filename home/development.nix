{ pkgs, ... }:
{
  home.packages = with pkgs; [
    claude-code
    cline
    go
    godot_4
    jdk
    nodejs
    vscode
  ];
}
