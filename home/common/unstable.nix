{ pkgs, ... }:
{
  home.packages = with pkgs; [
    herdr
  ];
}
