# macOS-only Home Manager config (normandy).
{ username, ... }:
{
  home.sessionVariables.NH_DARWIN_FLAKE = "/Users/${username}/nixos-config";

  programs.zsh.shellAliases.rebuild = "cd $NH_DARWIN_FLAKE && git pull && nh darwin switch -H normandy";
}
