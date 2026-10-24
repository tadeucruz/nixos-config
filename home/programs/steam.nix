# Steam session glue (Steam itself comes from `programs.steam` in modules/gaming.nix):
# the autostart entry.
#
# Proton/gaming env vars are NOT set here. `home.sessionVariables` is not part of
# the session Steam actually runs in (on citadel/legion it is started by
# `steam-launcher.service`, and on prothean by this autostart entry), so the vars
# live where they are actually honoured:
#   citadel/legion -> modules/jovian.nix (`jovian.steam.environment`)
#   prothean       -> hosts/prothean/configuration.nix (`environment.sessionVariables`)
{ ... }:
{
  xdg.configFile."autostart/steam.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Steam
    Exec=steam -silent -pipewire
    Icon=steam
    Terminal=false
  '';
}
