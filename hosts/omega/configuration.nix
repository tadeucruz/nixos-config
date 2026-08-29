# omega — home server (NixOS stable 26.05): Samba/btrfs NAS, *arr apps,
# HAOS VM, HermesAgent LXC, Cloudflare Tunnel.
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
    ../../modules/server/libvirt.nix
    ../../modules/server/lxc.nix
    ../../modules/server/podman.nix
    ../../modules/server/services/samba.nix
    ../../modules/server/services/cloudflared.nix
    ../../modules/server/services/haos.nix
    ../../modules/server/services/hermesagent.nix
    ../../modules/server/services/arr.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  # btrfs disks — storage is host-specific, kept close to the host (same
  # pattern as citadel's /GAMES). TODO: replace the placeholder UUIDs with the
  # real disks (`blkid`).
  fileSystems = {
    "/mnt/media" = {
      device = "/dev/disk/by-uuid/REPLACE-ME-MEDIA";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "discard=async"
        "noatime"
        "nofail"
        "space_cache=v2"
      ];
    };

    "/mnt/backup" = {
      device = "/dev/disk/by-uuid/REPLACE-ME-BACKUP";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "discard=async"
        "noatime"
        "nofail"
        "space_cache=v2"
      ];
    };
  };

  networking.hostName = hostname;

  system.stateVersion = "26.05";
}
