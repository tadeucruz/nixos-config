# Ghostty advertises TERM=xterm-ghostty; NixOS hosts need the matching terminfo
# or ncurses apps (tmux, htop) and shell init fail over SSH. Linux-only: on
# darwin the Ghostty app already ships it.
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.ghostty.terminfo ];
}
