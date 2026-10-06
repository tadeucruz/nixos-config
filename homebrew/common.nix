# Homebrew baseline (any Mac): enable the nix-darwin homebrew module, fish
# integration, and cleanup/upgrade policy. No packages — those live in
# per-purpose files (normandy.nix, development.nix).
{ ... }:
{
  homebrew = {
    enable = true;
    enableFishIntegration = true;
    onActivation = {
      cleanup = "zap";
      upgrade = true;
    };
  };
}
