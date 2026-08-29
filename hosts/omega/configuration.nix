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

  networking = {
    hostName = hostname;
    networkmanager.enable = lib.mkForce false;
    useDHCP = false;

    interfaces.enp1s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.0.2";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = "192.168.0.1";
    nameservers = [ "1.1.1.1" ];
  };

  system.stateVersion = "26.05";
}
