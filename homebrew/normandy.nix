# normandy-only personal/hardware apps via Homebrew (not dev tooling — that's
# development.nix). Only apps with no nixpkgs darwin equivalent — or that need a
# stable path so macOS TCC permissions survive rebuilds (rectangle) — live here;
# ghostty/zoom (and other nixpkgs-supported apps) are in home/programs/. Dock and
# activation scripts live in modules/normandy.nix.
{ ... }:
{
  homebrew = {
    brews = [ "displayplacer" ];
    casks = [
      "appcleaner"
      "balenaetcher"
      "bitwarden"
      "comfy"
      "crossover"
      "cryptomator"
      "rectangle"
      "steam"
      "ungoogled-chromium"
      "unsloth"
    ];
    masApps = {
      WhatsApp = 310633997;
      Infuse = 1136220934;
    };
  };
}
