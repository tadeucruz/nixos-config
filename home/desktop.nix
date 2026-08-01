# Shared Home Manager config for desktop machines (citadel + g15).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vscode
    claude-code
  ];

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
  };

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;

    settings = {
      horizontal = true;
      position = "top";
    };
  };
}
