{ pkgs, ... }:
{
  home.packages = with pkgs; [
    go
    godot_4
    jdk
    nodejs
    vscode
  ];
}
