{
  pkgs,
  lib,
  ...
}:
let
  release = "0.4.1";
  pname = "xodus-nexus";

  src = pkgs.fetchurl {
    url = "https://github.com/domsvoboda/xodus-nexus/releases/download/v${release}/Xodus-Nexus-${release}-x86_64.AppImage";
    hash = "sha256-O6XM5qPYS+w9eyKGz4eIhvC43Tpq6nY1q+N2oCN9vU0=";
  };

  # Extracted AppDir of the AppImage, for the launcher's .desktop entry and
  # icons (installed below; the FHS env itself only ships the bin symlink).
  appimageContents = pkgs.appimageTools.extract {
    inherit pname src;
    version = "latest";
  };
in
pkgs.appimageTools.wrapType2 {
  inherit pname src;

  # "latest" keeps the store path stable across bumps (like proton-ge-latest).
  version = "latest";

  # 32-bit support is required: launching a game dies with
  # "/lib/ld-linux.so.2: could not open" without it (some link in the launch
  # chain needs the 32-bit loader inside the FHS env, even though the runtime's
  # wine/wineserver, prefix bootstrap and VC++ redist are all x86_64).
  # The i686 half of the FHS libraries is no longer in the binary cache, so the
  # first build compiles it locally — after that it stays in the store.
  multiArch = true;

  extraPkgs =
    pkgs2: with pkgs2; [
      # The Nexus runtime's `proton` script is `#!/usr/bin/env python3`; NixOS
      # has no system python3, so prefix creation (`proton run cmd /c exit`)
      # died with "python3: No such file or directory" and games failed with
      # "The Proton prefix was not prepared correctly".
      python3
      webkitgtk_4_1 # Microsoft account sign-in (the backend's own WebView)
      gnutls # Wine loads it dynamically for Xbox sign-in / crypto
      libgudev # managed runtime's GStreamer device support
      libopus
      # "Add to Steam" imports shortcuts by invoking /usr/bin/steam inside the
      # FHS env — forward to the host's Steam instead of bundling another one.
      (writeShellScriptBin "steam" ''
        for launcher in /run/current-system/sw/bin/steam \
          "/etc/profiles/per-user/$USER/bin/steam" "$HOME/.nix-profile/bin/steam"; do
          if [ -x "$launcher" ]; then
            exec "$launcher" "$@"
          fi
        done
        echo "Steam is not installed in a Nix profile." >&2
        exit 127
      '')
    ];

  extraInstallCommands = ''
        # Install the launcher's .desktop entry and icons from the AppDir.
        desktop="$(find ${appimageContents} -maxdepth 4 -name '*.desktop' ! -name 'AppRun' | head -n1)"
        if [ -z "$desktop" ]; then
          echo "xodus-nexus: no .desktop file found in the extracted AppImage" >&2
          exit 1
        fi
        install -Dm444 "$desktop" $out/share/applications/xodus-nexus.desktop
        # Upstream's Exec points at its own AppRun; ours is the wrapper below,
        # which already carries the flags Electron needs on NixOS.
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

        # Replace the FHS bin symlink with a wrapper forcing the flags Electron
        # needs on NixOS/gamescope:
        #   --no-sandbox        the AppImage's chrome-sandbox cannot be setuid here
        #   --password-store=basic  keep Chromium out of the KWallet, which is
        #     locked at session start (e.g. gamescope autologin on citadel/legion).
        #   (The launcher's real Microsoft credentials still go to the wallet via
        #    its own D-Bus Secret Service flow in keyring.ts — untouched by this.)
        # APPIMAGE advertises this wrapper as the persistent launcher path: the
        # app derives "Add to Steam"/desktop shortcuts from it (index.ts), and
        # without it both APPIMAGE and the /.mount_ execPath checks come up empty
        # ("Shortcuts require an installed Linux launcher or AppImage with a
        # persistent executable path"). It is not a writable AppImage, so the
        # in-app launcher updater stays disabled — updates come from Nix.
        mv $out/bin/xodus-nexus $out/bin/.xodus-nexus-wrapped
        cat > $out/bin/xodus-nexus <<EOF
    #!/bin/sh
    export APPIMAGE="$out/bin/xodus-nexus"
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
