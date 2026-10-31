# MangoHud overlay, horizontal at the top of the window.
#
# `no_display` keeps the HUD hidden on startup (so it never shows up unasked in
# apps like Zed); Right Shift + F12 toggles it. `toggle_hud` is upstream's
# default too — spelled out here so the binding does not drift with updates.
# Note: the keybind is read from the app's input events, so Wayland-native
# games may not react to it (Proton/Steam games do).
{ ... }:
{
  programs.mangohud = {
    enable = true;
    enableSessionWide = true;

    settings = {
      horizontal = true;
      position = "top";
      no_display = true;
      toggle_hud = "Shift_R+F12";
    };
  };
}
