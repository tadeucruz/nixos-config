# legion — Legion Go (APU AMD Z1 Extreme). Handheld.
{ config, pkgs, lib, username, hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/jovian.nix
    ../../modules/btrfs-tuning.nix
  ];

  networking.hostName = hostname;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "uinput" "uhid" "hid_lenovo_go" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Nix doesn't wire a package's bundled udev rules in automatically like RPM/pacman
  # do; without this the hid-lenovo-go quirks never apply and InputPlumber sees no controller.
  services.udev.packages = [ pkgs.inputplumber ];

  # steamos-manager (pulled in by jovian.steam) always forces InputPlumber's gamepad
  # target to "deck-uhid", a HID protocol only the Steam client understands. InputPlumber's
  # own shipped profile for the original Legion Go defaults to "xbox-elite" instead (a
  # generic gamepad any app, including plain KDE, can read) — this waits for InputPlumber
  # to come up and re-asserts that default over D-Bus.
  # See: https://github.com/ShadowBlip/InputPlumber/issues/378#issuecomment-3179245818
  systemd.services.inputplumber-generic-gamepad = {
    description = "Force InputPlumber to emulate a generic gamepad instead of deck-uhid";
    after = [ "inputplumber.service" "steamos-manager.service" ];
    wants = [ "inputplumber.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "inputplumber-generic-gamepad" ''
        for i in $(seq 1 30); do
          if ${pkgs.systemd}/bin/busctl --system introspect org.shadowblip.InputPlumber /org/shadowblip/InputPlumber/CompositeDevice0 >/dev/null 2>&1; then
            exec ${pkgs.systemd}/bin/busctl --system call org.shadowblip.InputPlumber /org/shadowblip/InputPlumber/CompositeDevice0 org.shadowblip.Input.CompositeDevice SetTargetDevices as 3 xbox-elite mouse keyboard
          fi
          sleep 1
        done
        exit 1
      '';
    };
  };

  system.stateVersion = "26.05";
}