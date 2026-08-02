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
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
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
  systemd.tmpfiles.rules = [
    "L+ /var/lib/decky-loader/plugins/LegionGoRemapper - - - - ${legionGoRemapper}"
  ];

  networking.hostName = hostname;

  # Nix doesn't wire a package's bundled udev rules in automatically like RPM/pacman
  # do; without this the hid-lenovo-go quirks never apply and InputPlumber sees no controller.
  services.udev.packages = [ pkgs.inputplumber ];

  system.stateVersion = "26.05";
}
