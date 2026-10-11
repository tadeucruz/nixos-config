# Flutter SDK (Linux dev build) — no home-manager module, package wrapper only.
# normandy gets Flutter via the Homebrew cask, so this is prothean-only.
{ pkgs, ... }:
{
  home.packages = [ pkgs.flutter ];
}
