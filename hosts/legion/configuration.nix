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

  powerControl = pkgs.stdenvNoCC.mkDerivation {
    pname = "PowerControl";
    version = builtins.replaceStrings [ "." ] [ "-" ] "3.15.1";

    src = pkgs.fetchurl {
      url = "https://github.com/mengmeet/PowerControl/releases/download/v3.15.1/PowerControl.tar.gz";
      sha256 = "sha256-P91xmeSZbUbQqgnHJwf6l+8JcdIeZBkZlPfDsfG3iI4=";
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      tar xzf "$src" -C $out --strip-components=1
      runHook postInstall
    '';

    meta = {
      description = "Decky Loader power control plugin (TDP, GPU, boost per-game)";
      homepage = "https://github.com/mengmeet/PowerControl";
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
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-deckify;
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
    ln -sfn ${powerControl} ${config.jovian.decky-loader.stateDir}/plugins/PowerControl
  '';

  networking.hostName = hostname;

  # Nix doesn't wire a package's bundled udev rules in automatically like RPM/pacman
  # do; without this the hid-lenovo-go quirks never apply and InputPlumber sees no controller.
  services.udev.packages = [ pkgs.inputplumber ];

  # PowerStation: TDP/perf daemon (DBus). The SteamOS-Manager exposes no working
  # TDP control on the Legion Go (no power1_cap, EC-only), so this is the real
  # way to set TDP (5-35W), GPU clocks and governor from the QAM/Decky.
  services.powerstation.enable = true;

  # PowerStation resolves hwdata via xdg data dirs (prefix "hwdata"); without it
  # GPU discovery fails with "Config base path not found".
  systemd.services.powerstation.environment.XDG_DATA_DIRS =
    lib.mkForce "${pkgs.hwdata}/share:/run/current-system/sw/share";

  system.stateVersion = "26.05";
}
