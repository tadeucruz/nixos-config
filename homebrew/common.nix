{ ... }:
{
  homebrew = {
    enable = true;
    enableZshIntegration = true;
    onActivation.cleanup = "zap";
  };
}
