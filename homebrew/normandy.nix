# normandy-only personal/hardware apps via Homebrew (not dev tooling — that's
# development.nix). Only apps with no nixpkgs darwin equivalent live here;
# ghostty/rectangle/zoom (and other nixpkgs-supported apps) are in
# home/programs/. Dock and activation scripts live in modules/normandy.nix.
{ ... }:
{
  homebrew = {
    brews = [ "displayplacer" ];
    casks = [
      "appcleaner"
      "balenaetcher"
      "betterdisplay"
      "bitwarden"
      "comfy"
      "crossover"
      "cryptomator"
      "steam"
      "ungoogled-chromium"
    ];
    masApps = {
      WhatsApp = 310633997;
      Infuse = 1136220934;
    };
  };
}
