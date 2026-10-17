{ pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  security.sudo.extraConfig = "Defaults passwd_timeout=0";

  time.timeZone = "America/Sao_Paulo";

  # Ghostty advertises TERM=xterm-ghostty; remote NixOS hosts need the matching
  # terminfo or ncurses apps (tmux, htop) and shell init fail over SSH.
  environment.systemPackages = [ pkgs.ghostty.terminfo ];
}
