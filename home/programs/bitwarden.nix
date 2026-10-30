# Bitwarden desktop — no home-manager module, package wrapper only (nixpkgs
# ships the official Electron app; the flatpak is gone). Also points
# SSH_AUTH_SOCK at the agent socket the desktop app exposes (native install
# path — not the flatpak/snap one).
{ pkgs, ... }:
{
  home.packages = [ pkgs.bitwarden-desktop ];

  home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
}
