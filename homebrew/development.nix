# Mobile dev toolchain via Homebrew (darwin only — no home-manager equivalent).
# Homebrew has no home-manager equivalent, so these packages are installed by
# nix-darwin's homebrew module. The Xcode activation (xcode-select/license)
# lives in modules/darwin/xcode.nix.
{ ... }:
{
  homebrew = {
    brews = [
      "cocoapods"
      "llama.cpp"
    ];
    casks = [
      "android-studio"
      "flutter"
    ];
    masApps = {
      Xcode = 497799835;
    };
  };
}
