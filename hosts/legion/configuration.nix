# legion — Legion Go (APU AMD Z1 Extreme). Handheld.
# Starting simple: stock kernel + handheld-daemon.
# If hardware support is lacking, plug in Jovian (input already prepared in flake.nix).
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

  # --- APU AMD (Z1 Extreme) ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # The Legion Go screen is mounted rotated 90°. Adjust if image comes out sideways
  # (left_side_up / right_side_up / upside_down).
  boot.kernelParams = [ "video=eDP-1:panel_orientation=right_side_up" ];

  # Handheld Daemon: controls, TDP, buttons and Legion Go RGB.
  # (Requires recent nixpkgs. Comment this block if eval complains about the option.)
  services.handheld-daemon = {
    enable = true;
    user = username;
  };

  # Boot directly into a Steam/gamescope session (same approach as htpc).
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.gamescope}/bin/gamescope --steam -e -- steam -tenfoot -steamdeck";
      user = username;
    };
  };

  system.stateVersion = "26.05";
}
