# EasyEffects — PipeWire DSP (equalizer, etc.) for the Dell G15 speakers.
# No home-manager module, package wrapper only; the app ships its own LV2/LADSPA
# plugins. Open it once and tune the output effects by ear. prothean only.
{ pkgs, ... }:
{
  home.packages = [ pkgs.easyeffects ];
}
