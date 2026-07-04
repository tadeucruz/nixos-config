# htpc — AMD desktop (CPU + GPU), SteamOS-like experience without Jovian.
{ config, pkgs, lib, username, hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/gaming.nix
  ];

  networking.hostName = hostname;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];

  # --- AMD GPU ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Boot directly into a Steam/gamescope session via greetd autologin.
  # This is the SteamOS-like approach without Jovian — greetd launches
  # gamescope wrapping Steam in Big Picture mode.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.gamescope}/bin/gamescope --steam -e -- steam -tenfoot -steamdeck";
      user = username;
    };
  };

  system.stateVersion = "26.05";
}
