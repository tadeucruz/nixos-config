# Ghostty terminal — darwin only: `pkgs.ghostty` is the GTK build (Linux-only),
# the macOS app comes from the official signed dmg via `ghostty-bin`
# (Ghostty.app + `ghostty` CLI wrapper + bundled terminfo). Remote-host terminfo
# is provided by modules/common/ghostty.nix on the NixOS side.
{ pkgs, ... }:
{
  home.packages = [ pkgs.ghostty-bin ];
}
