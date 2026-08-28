# Personal apps installed via Homebrew — normandy only, not dev tooling.
# displayplacer backs the display script in modules/normandy.nix.
{ ... }:
{
  homebrew = {
    brews = [ "displayplacer" ];
    casks = [
      "betterdisplay"
      "bitwarden"
      "cryptomator"
      "rectangle"
      "zoom"
    ];
    masApps = {
      WhatsApp = 310633997;
    };
  };
}
