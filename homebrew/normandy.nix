# normandy-only personal/hardware apps via Homebrew (not dev tooling — that's
# development.nix). Casks/brews/masApps only; dock and activation scripts live
# in modules/normandy.nix.
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
      "ghostty"
      "rectangle"
      "steam"
      "ungoogled-chromium"
      "zoom"
    ];
    masApps = {
      WhatsApp = 310633997;
      Infuse = 1136220934;
    };
  };
}
