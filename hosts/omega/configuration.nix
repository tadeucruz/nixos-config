{
  hostname,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common/all.nix
    ../../modules/common/nix.nix
    ../../modules/common/locale.nix
    ../../modules/common/zsh.nix
    ../../modules/common/zram.nix
    ../../modules/boot/base.nix
    ../../modules/users/base.nix
    ../../modules/users/server.nix
    ../../modules/networking/firewall.nix
    ../../modules/services/avahi.nix
    ../../modules/services/openssh.nix
    ../../modules/services/tailscale.nix
    ../../modules/services/sonarr.nix
    ../../modules/btrfs-tuning.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  networking = {
    hostName = hostname;
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

  fileSystems."/Media" = {
    device = "/dev/disk/by-uuid/f8034984-36e9-4a4a-8521-e0ffa3cda5b1";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
      "discard=async"
      "noatime"
      "nofail"
      "space_cache=v2"
    ];
  };

  systemd.tmpfiles.rules = [ "d /Media 2775 root media - -" ];

  system.stateVersion = "26.05";
}
