{ ... }:
{
  homebrew = {
    brews = [ "cocoapods" ];
    casks = [
      "android-studio"
      "flutter"
    ];
    masApps = {
      Xcode = 497799835;
    };
  };

  system.activationScripts.postActivation.text = ''
    if [ -d /Applications/Xcode.app ]; then
      /usr/bin/xcode-select -s /Applications/Xcode.app/Contents/Developer \
        || echo "postActivation: xcode-select failed" >> /tmp/darwin-activation.log
      /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept >/dev/null 2>&1 \
        || echo "postActivation: xcodebuild -license accept failed" >> /tmp/darwin-activation.log
    fi
  '';
}
