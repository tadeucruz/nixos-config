# macOS-only Home Manager config.
{ pkgs, username, hostname, ... }:
{
  home = {
    sessionVariables = {
      NH_DARWIN_FLAKE = "/Users/${username}/nixos-config";
      SSH_AUTH_SOCK = "/Users/${username}/.bitwarden-ssh-agent.sock";
    };
    packages = with pkgs; [
      bitwarden-desktop
      betterdisplay
      obsidian
      rectangle
    ];
  };

  programs = {
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      darwinFlake = "/Users/${username}/nixos-config";
    };
    zsh.shellAliases.rebuild = "cd $NH_DARWIN_FLAKE && git pull && nh darwin switch -H ${hostname}";
  };
}
