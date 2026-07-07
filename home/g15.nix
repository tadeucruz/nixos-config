{ pkgs, lib, ... }:
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    vscode
    claude-code
  ];

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
  };
}
