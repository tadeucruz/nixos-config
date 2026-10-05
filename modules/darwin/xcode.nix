# Xcode activation (darwin only): point xcode-select at the Xcode app and
# accept the license. Idempotent — only acts if /Applications/Xcode.app exists.
# The Xcode masApp itself lives in homebrew/development.nix.
{ ... }:
{
  system.activationScripts.postActivation.text = ''
    if [ -d /Applications/Xcode.app ]; then
      /usr/bin/xcode-select -s /Applications/Xcode.app/Contents/Developer \
        || echo "postActivation: xcode-select failed" >> /tmp/darwin-activation.log
      /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept >/dev/null 2>&1 \
        || echo "postActivation: xcodebuild -license accept failed" >> /tmp/darwin-activation.log
    fi
  '';
}
