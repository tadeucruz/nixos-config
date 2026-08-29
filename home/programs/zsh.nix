# Cross-platform zsh config (aliases, plugins).
{ ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -alh";
    };
  };
}
