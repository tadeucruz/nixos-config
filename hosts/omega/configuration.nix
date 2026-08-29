# omega — home server (NixOS stable 26.05). Kept minimal on purpose: modules
# are imported one by one as they're tested during the Proxmox migration.
{
  config,
  lib,
  pkgs,
  hostname,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/server/base.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  networking.hostName = hostname;

  system.stateVersion = "26.05";
}
