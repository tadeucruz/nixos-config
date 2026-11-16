# normandy-only personal/hardware apps via Homebrew (not dev tooling — that's
# development.nix). Repo rule: GUI apps live here as casks — /Applications is a
# stable path (TCC permissions survive rebuilds) and each app's own auto-updater
# keeps working. CLI tools and config-managed apps stay in nix (home/programs/).
# Dock and activation scripts live in modules/normandy.nix.
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
      "element"
      "ghostty"
      "obsidian"
      "rectangle"
      "steam"
      "ungoogled-chromium"
      "unsloth"
      "vscodium"
      "zed"
      "zoom"
    ];
    masApps = {
      WhatsApp = 310633997;
      Infuse = 1136220934;
    };
  };
}
