{
  pkgs,
  lib,
  ...
}:
let
  release = "0.4.3";
  pname = "xodus-nexus";

  src = pkgs.fetchurl {
    url = "https://github.com/domsvoboda/xodus-nexus/releases/download/v${release}/Xodus-Nexus-${release}-x86_64.AppImage";
    hash = "sha256-bphrk9FT3MbCN8FahF2iIr50SGe1lSI4Gseiouqj4ds=";
  };

  appimageContents = pkgs.appimageTools.extract {
    inherit pname src;
    version = "latest";
  };
in
pkgs.appimageTools.wrapType2 {
  inherit pname src;
  version = "latest";

  # Game launch needs the 32-bit loader in the FHS env (/lib/ld-linux.so.2).
  multiArch = true;

  extraPkgs =
    pkgs2: with pkgs2; [
      # The runtime's proton script is `#!/usr/bin/env python3`.
      python3
      webkitgtk_4_1 # Microsoft account sign-in
    ];

  extraInstallCommands = ''
    # .desktop entry and icons from the AppDir.
    desktop="$(find ${appimageContents} -maxdepth 4 -name '*.desktop' ! -name 'AppRun' | head -n1)"
    if [ -z "$desktop" ]; then
      echo "xodus-nexus: no .desktop file found in the extracted AppImage" >&2
      exit 1
    fi
    install -Dm444 "$desktop" $out/share/applications/xodus-nexus.desktop
    sed -i 's|^Exec=.*|Exec=xodus-nexus|' $out/share/applications/xodus-nexus.desktop

    if [ -d ${appimageContents}/usr/share/icons ]; then
      mkdir -p $out/share
      cp -r ${appimageContents}/usr/share/icons $out/share/icons
      chmod -R u+w $out/share/icons
    fi
    if [ -d ${appimageContents}/usr/share/pixmaps ]; then
      mkdir -p $out/share
      cp -r ${appimageContents}/usr/share/pixmaps $out/share/pixmaps
      chmod -R u+w $out/share/pixmaps
    fi

    # Electron on NixOS: no setuid chrome-sandbox, keyring locked at gamescope
    # autologin; APPIMAGE is how the app derives Steam/desktop shortcuts; Steam
    # shortcut envs break the FHS env (LD_LIBRARY_PATH/LD_PRELOAD).
    mv $out/bin/xodus-nexus $out/bin/.xodus-nexus-wrapped
    cat > $out/bin/xodus-nexus <<EOF
    #!/bin/sh
    export APPIMAGE="$out/bin/xodus-nexus"
    unset LD_LIBRARY_PATH LD_PRELOAD
    exec $out/bin/.xodus-nexus-wrapped --no-sandbox --password-store=basic "\$@"
    EOF
    chmod 0755 $out/bin/xodus-nexus
  '';

  meta = {
    description = "Xbox-inspired launcher for Microsoft Store / Game Pass PC games on Linux";
    homepage = "https://github.com/domsvoboda/xodus-nexus";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
