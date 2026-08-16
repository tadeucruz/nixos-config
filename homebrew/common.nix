# Homebrew bootstrap shared by any Mac that uses Homebrew.
{ ... }:
{
  homebrew = {
    enable = true;
    enableZshIntegration = true;
    onActivation.cleanup = "zap";
  };
}
