{ pkgs, lib, ... }:
{
  imports = [ ./common.nix ];

  # Laptop-only user packages.
  home.packages = with pkgs; [
    vscode
    claude-code
  ];

  # Bitwarden SSH agent socket.
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
  };

}
