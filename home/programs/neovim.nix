{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim
    gcc
    ripgrep
    fd
    unzip
  ];

  xdg.configFile.nvim.source = ./neovim;
}
