# Shared Home Manager config for gaming (citadel + g15 + legion).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    protonplus
  ];

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;

    settings = {
      horizontal = true;
      position = "top";
    };
  };
}
