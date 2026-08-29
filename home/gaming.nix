{ ... }:
{
  imports = [
    ./programs/mangohud.nix
  ];

  home.sessionVariables = {
    PROTON_FSR4_UPGRADE = "1";
    PROTON_USE_NTSYNC = "1";
  };

  xdg.configFile."autostart/steam.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Steam
    Exec=steam -silent -pipewire
    Icon=steam
    Terminal=false
  '';
}
