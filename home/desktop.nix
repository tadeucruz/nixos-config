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
}
