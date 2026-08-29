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
    ../../modules/common/all.nix
    ../../modules/common/nix.nix
    ../../modules/common/locale.nix
    ../../modules/common/zsh.nix
    ../../modules/common/zram.nix
    ../../modules/boot/base.nix
    ../../modules/boot/gaming.nix
    ../../modules/users/base.nix
    ../../modules/users/gaming.nix
    ../../modules/networking/networkmanager.nix
    ../../modules/desktop/fonts.nix
    ../../modules/desktop/bluetooth.nix
    ../../modules/desktop/rtkit.nix
    ../../modules/desktop/rocm.nix
    ../../modules/desktop/kde.nix
    ../../modules/services/avahi.nix
    ../../modules/services/flatpak.nix
    ../../modules/services/fwupd.nix
    ../../modules/services/openssh.nix
    ../../modules/services/pipewire.nix
    ../../modules/services/syncthing.nix
    ../../modules/services/tailscale.nix
    ../../modules/jovian.nix
    ../../modules/gaming.nix
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

  networking.hostName = hostname;

  networking.networkmanager.wifi.powersave = false;

  services.inputplumber.enable = true;

  services.scx = {
    enable = true;
    package = lib.mkDefault pkgs.scx.rustscheds;
    scheduler = lib.mkDefault "scx_lavd";
  };

  systemd.services.scx.wantedBy = lib.mkOverride 0 [ "multi-user.target" ];

  services.udev.packages = [ pkgs.inputplumber ];

  jovian.decky-loader.extraPackages = with pkgs; [ hidapi ];
  systemd.services.decky-loader.environment.LD_LIBRARY_PATH = "${pkgs.hidapi}/lib";

  systemd.services.decky-loader.preStart = lib.mkAfter ''
    mkdir -p ${config.jovian.decky-loader.stateDir}/plugins
    ln -sfn ${legionGoRemapper} ${config.jovian.decky-loader.stateDir}/plugins/LegionGoRemapper
  '';

  system.stateVersion = "26.05";
}
