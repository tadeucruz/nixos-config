# Shared Home Manager config for gaming (citadel + prothean + legion).
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    protonplus
  ];

  home.sessionVariables = {
    PROTON_USE_NTSYNC = "1";
  };

  # programs.mangohud = {
  #   enable = true;
  #   enableSessionWide = true;
  #
  #   settings = {
  #     horizontal = true;
  #     position = "top";
  #   };
  # };

  xdg.configFile."autostart/steam.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Steam
    Exec=steam -silent -pipewire
    Icon=steam
    Terminal=false
  '';
}
