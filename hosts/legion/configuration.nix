# legion — Legion Go (APU AMD Z1 Extreme). Handheld.
{
  config,
  pkgs,
  lib,
  username,
  hostname,
  ...
}:

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

  simpleDeckyTDP = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "simpledeckytdp";
    version = "1.0.5";

    src = pkgs.fetchurl {
      url = "https://github.com/aarron-lee/SimpleDeckyTDP/releases/download/v${version}/SimpleDeckyTDP.zip";
      hash = "sha256-6/HGgUe2MA7hfC1+oAqc/prBx4r3jTZNnTBqxkoswFc=";
    };

    nativeBuildInputs = [ pkgs.unzip ];

    dontConfigure = true;
    dontBuild = true;
    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      unzip "$src" -d "$out"
      rm -f $out/SimpleDeckyTDP/ota_update.sh

      # i18n.py hardcodes the SteamOS layout ($DECKY_USER_HOME/homebrew/plugins/...),
      # which doesn't match Jovian's stateDir. decky-loader already sets
      # DECKY_PLUGIN_DIR to the plugin's real location — use it instead.
      sed -i "s|{decky_plugin.DECKY_USER_HOME}/homebrew/plugins/SimpleDeckyTDP/i18n|{decky_plugin.DECKY_PLUGIN_DIR}/i18n|" $out/SimpleDeckyTDP/py_modules/i18n.py
      runHook postInstall
    '';

    meta = {
      description = "Decky TDP plugin for PC handhelds (uses Legion Go kernel WMI)";
      homepage = "https://github.com/aarron-lee/SimpleDeckyTDP";
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common/linux.nix
    ../../modules/gaming.nix
    ../../modules/jovian.nix
    ../../modules/btrfs-tuning.nix
  ];

  boot = {
    kernelModules = [
      "hid_lenovo_go"
      "uhid"
      "uinput"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # https://github.com/aarron-lee/LegionGoRemapper — legion_hid.py loads libhidapi via ctypes at runtime.
  jovian.decky-loader.extraPackages = with pkgs; [ hidapi ];
  systemd.services.decky-loader.environment.LD_LIBRARY_PATH = "${pkgs.hidapi}/lib";

  # Jovian's decky-loader module has no declarative "plugins" option — it just
  # scans jovian.decky-loader.stateDir (/var/lib/decky-loader/plugins by default,
  # owned by the system "decky" user, not $HOME). home.file was the wrong layer.
  #
  # systemd.tmpfiles.rules can't place the symlink either: the loader process
  # (runs as root) creates ./plugins itself as root under a decky-owned stateDir,
  # and tmpfiles refuses that ownership transition as an "unsafe path transition"
  # — it logs a warning and silently skips the rule instead of failing the switch.
  # Doing it in the service's own preStart (also root) sidesteps that check entirely.
  systemd.services.decky-loader.preStart = lib.mkAfter ''
    mkdir -p ${config.jovian.decky-loader.stateDir}/plugins
    ln -sfn ${legionGoRemapper} ${config.jovian.decky-loader.stateDir}/plugins/LegionGoRemapper
    ln -sfn ${simpleDeckyTDP}/SimpleDeckyTDP ${config.jovian.decky-loader.stateDir}/plugins/SimpleDeckyTDP

    # git is the source of truth for SimpleDeckyTDP's settings (15W battery / 30W on AC).
    # Overwrite on every boot so interface tweaks never persist past a reboot.
    mkdir -p ${config.jovian.decky-loader.stateDir}/settings/SimpleDeckyTDP
    cp ${./simpledeckytdp-settings.json} ${config.jovian.decky-loader.stateDir}/settings/SimpleDeckyTDP/settings.json
    chown decky:decky ${config.jovian.decky-loader.stateDir}/settings/SimpleDeckyTDP/settings.json
  '';

  networking.hostName = hostname;

  # MT7921e (Legion Go's WiFi) drops/stalls association with power save on —
  # observed 2026-08-26: repeated "association took too long" until it connects.
  # wifi.powersave = 2 disables it (NetworkManager config).
  networking.networkmanager.wifi.powersave = false;

  # Nix doesn't wire a package's bundled udev rules in automatically like RPM/pacman
  # do; without this the hid-lenovo-go quirks never apply and InputPlumber sees no controller.
  services.udev.packages = [ pkgs.inputplumber ];

  system.stateVersion = "26.05";
}
