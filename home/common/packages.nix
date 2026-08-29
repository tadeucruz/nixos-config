{ pkgs, ... }:
{
  home.packages = with pkgs; [
    btop
    curl
    ripgrep
    vim
    wget
  ];
}
