# Dev tooling and personal apps installed via Homebrew (normandy only).
{ ... }:
{
  homebrew = {
    brews = [ "displayplacer" "cocoapods" ];
    casks = [ "cryptomator" "android-studio" "flutter" ];
    masApps = {
      WhatsApp = 310633997;
      Xcode = 497799835;
    };
  };
}
