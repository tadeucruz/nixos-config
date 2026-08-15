# Shared system packages for all machines (cross-platform).
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    curl
    git
    vim
    wget
  ];
}
