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

  system.activationScripts.postActivation.text = ''
    # Accept the Xcode license and point xcode-select at the full Xcode install.
    # Runs after `brew bundle` (which installs Xcode via `mas`, see masApps above).
    if [ -d /Applications/Xcode.app ]; then
      /usr/bin/xcode-select -s /Applications/Xcode.app/Contents/Developer \
        || echo "postActivation: xcode-select failed" >> /tmp/darwin-activation.log
      /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept >/dev/null 2>&1 \
        || echo "postActivation: xcodebuild -license accept failed" >> /tmp/darwin-activation.log
    fi
  '';
}
