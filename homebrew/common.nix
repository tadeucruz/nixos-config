# Homebrew baseline (any Mac): enable the nix-darwin homebrew module, zsh
# integration, and cleanup/upgrade policy. No packages — those live in
# per-purpose files (normandy.nix, development.nix).
{ ... }:
{
  homebrew = {
    enable = true;
    enableZshIntegration = true;
    onActivation = {
      cleanup = "zap";
      upgrade = true;
    };
  };
}
