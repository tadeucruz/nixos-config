# Godot 4 game engine — no home-manager module, package wrapper only.
{ pkgs, ... }:
let
  # TODO(tadeucruz): REPORT UPSTREAM and then drop this workaround.
  #   - harfbuzz: `test/shape/data/in-house/tests/harfbust.tests` — the
  #     `@shapers=ot,coretext` entry must also expect the ligature on newer
  #     macOS (CoreText now resolves the HarfBust puzzle). Still present in
  #     14.6.0/main.
  #   - nixpkgs: harfbuzz build failure on aarch64-darwin (channel/PR for
  #     14.6.0 is #575692).
  #
  # Workaround: Godot builds harfbuzz (and its raster/icu variants) from source
  # on Darwin, and the failing checkPhase blocks Godot's whole closure. Override
  # just Godot's harfbuzz dependency rather than the global package set, which
  # would force rebuilds of everything using harfbuzz (Firefox, etc.). The lib
  # itself builds fine — only the test is stale.
  godot =
    if pkgs.stdenv.hostPlatform.isDarwin then
      pkgs.godot_4.override {
        harfbuzz = pkgs.harfbuzz.overrideAttrs (_: {
          doCheck = false;
        });
      }
    else
      pkgs.godot_4;
in
{
  home.packages = [ godot ];
}
