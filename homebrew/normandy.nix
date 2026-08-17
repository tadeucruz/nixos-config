# Personal apps installed via Homebrew — normandy only, not dev tooling.
# displayplacer backs the display script in modules/normandy.nix.
{ ... }:
{
  homebrew = {
    brews = [ "displayplacer" ];
    casks = [ "cryptomator" "zoom" ];
    masApps = {
      WhatsApp = 310633997;
    };
  };
}
