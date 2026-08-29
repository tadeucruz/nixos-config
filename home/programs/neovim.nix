# Neovim (LazyVim), meant to eventually replace VSCode — prothean + normandy.
# Config lives in ./neovim (java + go extras only). LSP servers themselves are
# installed by Mason at runtime, not nix; go/jdk toolchains come from
# development.nix. gcc/ripgrep/fd/unzip are here because LazyVim's core
# (treesitter, telescope, Mason downloads) needs them regardless of language.
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
