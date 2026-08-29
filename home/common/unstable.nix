# CLI packages only available on nixos-unstable (desktop/laptop machines).
# omega tracks nixpkgs-stable, so it must not import this.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    herdr
  ];
}
