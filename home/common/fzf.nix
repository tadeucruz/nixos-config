# Cross-platform fzf. Nushell integration needs fzf >= 0.73 (omega tracks
# nixpkgs-stable with an older fzf) and we don't use nushell anyway.
{ ... }:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = false;
    enableNushellIntegration = false;
  };
}
