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

  xdg.configFile."autostart/steam.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Steam
    Exec=gamemoderun steam -silent -pipewire
    Icon=steam
    Terminal=false
  '';
}
