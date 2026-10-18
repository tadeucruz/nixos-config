# Ungoogled Chromium — no home-manager module, package wrapper only (Linux only in nixpkgs).
{ pkgs, ... }:
{
  home.packages = [ pkgs.ungoogled-chromium ];
}
