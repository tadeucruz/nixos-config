# Zed editor — native home-manager module (Linux only: normandy's Zed comes from
# the Homebrew cask in homebrew/normandy.nix). Config lives at ~/.config/zed on
# both platforms (Zed keeps the XDG path on darwin), so the same module works on
# prothean.
#
# Gated here instead of in home/development.nix: `imports` cannot depend on
# `pkgs` (infinite recursion), the option value can.
{ lib, pkgs, ... }:
{
  programs.zed-editor.enable = !pkgs.stdenv.hostPlatform.isDarwin;
}
