# Node.js runtime — no home-manager module, package wrapper only.
{ pkgs, ... }:
{
  home.packages = [ pkgs.nodejs ];
}
