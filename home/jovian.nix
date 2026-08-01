# Shared Home Manager config for Jovian machines (legion only).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    protonplus
  ];
}
