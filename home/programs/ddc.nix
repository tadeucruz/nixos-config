# m1ddc — DDC/CI control of external displays on Apple Silicon. Package wrapper
# only (no home-manager module); hotkey mapping comes later once the CLI is
# explored by hand.
{ pkgs, ... }:
{
  home.packages = [ pkgs.m1ddc ];
}
