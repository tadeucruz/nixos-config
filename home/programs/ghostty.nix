{
  pkgs,
  ...
}:
{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.ghostty;
    enableZshIntegration = true;

    settings = {
      font-family = "JetBrainsMono Nerd Font";
      cursor-style = "block";
      mouse-hide-while-typing = true;
    };
  };
}
