# Declarative Homebrew install (darwin only): the Homebrew repo and its taps are
# pinned in flake.lock, so a fresh Mac needs no manual `brew install` bootstrap
# and the tap contents are reproducible. Only Homebrew itself is managed here —
# casks/formulae stay in homebrew/*.nix via nix-darwin's homebrew module.
{ inputs, username, ... }:
{
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  nix-homebrew = {
    enable = true;
    user = username;

    # Takes over the script-installed /opt/homebrew in place (one-way migration:
    # the prefix becomes a nix store symlink afterwards).
    autoMigrate = true;

    # Taps come from the flake inputs, so `brew tap` no longer works by design.
    mutableTaps = false;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
  };
}
