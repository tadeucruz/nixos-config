# Internal-speaker EQ for the Dell G15 5525 (prothean).
#
# Why this exists: the ALC3204 drives the internal speakers directly (there is
# no external amplifier on this machine) through a generic codec path, with no
# DSP of any kind. Windows compensates for these tiny drivers with Waves
# MaxxAudio, which is why the very same speakers sound muddy/muffled ("abafado")
# on Linux.
#
# This adds a corrective EQ as a WirePlumber "smart filter" (a PipeWire
# filter-chain driven by WirePlumber). WirePlumber links it *only* to the
# internal-speaker sink, so headphones (a different UCM profile, hence a
# different node name) and every other output are left untouched.
#
# To tune: edit the values in the `eq` block below and run
# `nixos-rebuild switch`. The speaker sink node name below is derived from the
# UCM profile; if a future kernel/UCM update renames it the EQ simply stops
# applying (nothing breaks) and the name must be updated here.
{ ... }:
let
  # Sink node of the internal speakers. Headphones use the "Headphones" UCM
  # profile, which produces a different node name, so they are not affected.
  speakerSink = "alsa_output.pci-0000_74_00.6.HiFi__Speaker__sink";

  # Corrective curve (Hz / dB). Defaults fight the "muffled" character:
  # drop what the small drivers cannot reproduce, cut the boxy low-mids and
  # lift presence + air to compensate for the missing vendor DSP.
  eq = {
    highPassFreq = 100.0; # rumble the tiny drivers cannot reproduce
    mudFreq = 350.0; # boxy "abafado" region
    mudGain = -2.5;
    presenceFreq = 2200.0; # intelligibility
    presenceGain = 2.0;
    airFreq = 4000.0;
    airGain = 4.5;
  };
in
{
  services.pipewire.wireplumber.extraConfig."50-speaker-eq" = {
    "wireplumber.profiles" = {
      main = {
        "filter.sink.speaker-eq" = "required";
      };
    };

    "wireplumber.components" = [
      {
        name = "libpipewire-module-filter-chain";
        type = "pw-module-client";
        provides = "filter.sink.speaker-eq";
        requires = [ "support.client-context" ];
        arguments = {
          "node.name" = "filter.sink.speaker-eq";
          "node.description" = "Speaker EQ (Dell G15)";
          "media.name" = "Speaker EQ (Dell G15)";
          "audio.channels" = 2;
          "audio.position" = [
            "FL"
            "FR"
          ];
          "filter.graph" = {
            nodes = [
              {
                type = "builtin";
                name = "highpass";
                label = "bq_highpass";
                control = {
                  "Freq" = eq.highPassFreq;
                  "Q" = 0.707;
                };
              }
              {
                type = "builtin";
                name = "mud";
                label = "bq_peaking";
                control = {
                  "Freq" = eq.mudFreq;
                  "Q" = 1.0;
                  "Gain" = eq.mudGain;
                };
              }
              {
                type = "builtin";
                name = "presence";
                label = "bq_peaking";
                control = {
                  "Freq" = eq.presenceFreq;
                  "Q" = 1.0;
                  "Gain" = eq.presenceGain;
                };
              }
              {
                type = "builtin";
                name = "air";
                label = "bq_highshelf";
                control = {
                  "Freq" = eq.airFreq;
                  "Q" = 0.7;
                  "Gain" = eq.airGain;
                };
              }
            ];
            links = [
              {
                output = "highpass:Out";
                input = "mud:In";
              }
              {
                output = "mud:Out";
                input = "presence:In";
              }
              {
                output = "presence:Out";
                input = "air:In";
              }
            ];
          };
          "capture.props" = {
            "media.class" = "Audio/Sink";
            "filter.smart" = true;
            "filter.smart.name" = "filter.sink.speaker-eq";
            "filter.smart.target" = {
              "node.name" = speakerSink;
            };
          };
          "playback.props" = {
            # keep the real sink suspended when nothing plays
            "node.passive" = true;
            "media.role" = "DSP";
          };
        };
      }
    ];
  };
}
