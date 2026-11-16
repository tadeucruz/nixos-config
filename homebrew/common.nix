# Homebrew baseline (any Mac): enable the nix-darwin homebrew module, zsh
# integration, and cleanup/upgrade policy. No packages — those live in
# per-purpose files (normandy.nix, development.nix).
{ config, ... }:
{
  homebrew = {
    enable = true;
    enableZshIntegration = true;

    # Homebrew itself (and its taps) are installed by modules/darwin/nix-homebrew.nix;
    # mirroring the pinned tap set here keeps `brew` from re-cloning them.
    taps = builtins.attrNames config.nix-homebrew.taps;

    onActivation = {
      # `zap` removes anything Homebrew manages but this config does not declare:
      # an app installed by hand (or tapped) is gone on the next rebuild.
      cleanup = "zap";

      # Upgrades belong to the user session, not to activation: the `rebuild`
      # alias (home/programs/zsh.nix) runs `brew upgrade` + `mas upgrade` before
      # `nh darwin switch`. Keeps activation fast and idempotent, and avoids brew
      # prompting for sudo/Gatekeeper mid-switch.
      upgrade = false;
    };
  };
}
