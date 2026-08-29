# Cross-platform CLI packages (all machines, including servers).
# herdr lives in ./unstable.nix (not available on nixpkgs-stable).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    btop
    curl
    ripgrep
    vim
    wget
  ];
}
