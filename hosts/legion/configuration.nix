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
    pname = "SimpleDeckyTDP";
    version = "1.0.5";

    src = pkgs.fetchzip {
      url = "https://github.com/aarron-lee/SimpleDeckyTDP/releases/download/v${version}/SimpleDeckyTDP.zip";
      hash = "sha256-0D02/F8XDCJi/hq+hlPp/d38n4kKPY68ODMCHdOpHAM=";
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r . $out/
      runHook postInstall
    '';

    meta = {
      description = "Decky Loader TDP/GPU plugin — uses Lenovo's WMI firmware-attributes on Legion Go, not ryzenadj";
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

  systemd.services.decky-loader.preStart = lib.mkAfter ''
    mkdir -p ${config.jovian.decky-loader.stateDir}/plugins
    ln -sfn ${legionGoRemapper} ${config.jovian.decky-loader.stateDir}/plugins/LegionGoRemapper
    ln -sfn ${simpleDeckyTDP} ${config.jovian.decky-loader.stateDir}/plugins/SimpleDeckyTDP
  '';

  networking.hostName = hostname;

  services.udev.packages = [ pkgs.inputplumber ];

  # SimpleDeckyTDP hardcodes $HOME/homebrew/plugins/SimpleDeckyTDP in a few
  # places (i18n dir, ryzenadj fallback, self-update) instead of using
  # DECKY_PLUGIN_DIR; without it i18n.LANGS stays None and any translation
  # call throws.
  systemd.tmpfiles.rules = [
    "d /home/${username}/homebrew/plugins 0755 ${username} users -"
    "L+ /home/${username}/homebrew/plugins/SimpleDeckyTDP - - - - ${simpleDeckyTDP}"
  ];

  system.stateVersion = "26.05";
}
