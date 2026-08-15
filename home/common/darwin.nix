# macOS-only Home Manager config (normandy).
{ pkgs, username, ... }:
{
  home = {
    sessionVariables.NH_DARWIN_FLAKE = "/Users/${username}/nixos-config";
    packages = with pkgs; [ nh ];
  };

  programs.zsh.shellAliases.rebuild = "cd $NH_DARWIN_FLAKE && git pull && nh darwin switch -H normandy";
}
