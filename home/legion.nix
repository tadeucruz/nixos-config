{ pkgs, ... }:

let
  legionGoRemapper = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "legion-go-remapper";
    version = "0.3.0";

    src = pkgs.fetchzip {
      url = "https://github.com/aarron-lee/LegionGoRemapper/releases/download/v${version}/LegionGoRemapper.tar.gz";
      hash = "sha256-JqUXzU/kiHg8AZtBPTkcBvXtNYDnOdXOy4mHkIC30Wg=";
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r . $out/
      rm -f $out/ota_update.sh
      runHook postInstall
    '';

    meta = {
      description = "Decky Loader plugin for Legion Go button remapping";
      homepage = "https://github.com/aarron-lee/LegionGoRemapper";
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  imports = [
    ./common.nix
    ./gaming.nix
  ];

  # Decky Loader reads plugins from here; ota_update.sh is stripped in the
  # derivation above since its self-update would fight this managed symlink.
  home.file."homebrew/plugins/LegionGoRemapper".source = legionGoRemapper;

  xdg.desktopEntries.return-to-steam = {
    name = "Return to Steam";
    comment = "Switch back to Steam Big Picture session";
    exec = "start-gamescope-session";
    icon = "steam";
    terminal = false;
    categories = [ "Game" ];
  };
}
