# macOS-only Home Manager config.
{ pkgs, username, hostname, ... }:
{
  home = {
    sessionVariables = {
      NH_DARWIN_FLAKE = "/Users/${username}/nixos-config";
      SSH_AUTH_SOCK = "/Users/${username}/.bitwarden-ssh-agent.sock";
    };
    packages = with pkgs; [
      nh
      bitwarden-desktop
      betterdisplay
    ];
  };

  programs.zsh.shellAliases.rebuild = "cd $NH_DARWIN_FLAKE && git pull && nh darwin switch -H ${hostname}";
}
