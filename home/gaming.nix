# Shared Home Manager config for gaming (citadel + prothean + legion).
{ ... }:
{
  home.sessionVariables = {
    # Proton-CachyOS: automatically download amdxcffx64.dll and upgrade games
    # with FSR 3.1 to FSR 4. Only effective with Proton-CachyOS selected for the
    # game and an RDNA4 GPU (citadel); ignored elsewhere.
    PROTON_FSR4_UPGRADE = "1";
    PROTON_USE_NTSYNC = "1";
  };

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
    Exec=steam -silent -pipewire
    Icon=steam
    Terminal=false
  '';
}
