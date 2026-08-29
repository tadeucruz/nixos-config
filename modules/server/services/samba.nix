# Samba file sharing (omega) — replaces OMV's Samba. The btrfs disks are
# mounted in hosts/omega/configuration.nix (host-specific storage, same
# pattern as citadel's /GAMES); this module only exports them as SMB shares.
#
# TODO: set the SMB password once: `smbpasswd -a tadeucruz`.
{ ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "server string" = "omega NAS";
        "workgroup" = "WORKGROUP";
        "security" = "user";
        "map to guest" = "Never";
        "server min protocol" = "SMB2";
        "hosts allow" = "127.0.0.1 192.168.0.0/16";
      };

      media = {
        path = "/mnt/media";
        browseable = "yes";
        "read only" = "no";
        "valid users" = "tadeucruz";
      };

      backup = {
        path = "/mnt/backup";
        browseable = "yes";
        "read only" = "no";
        "valid users" = "tadeucruz";
      };
    };
  };
}
