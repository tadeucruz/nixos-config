# *arr stack (omega) — qBittorrent + Prowlarr + Sonarr + Radarr + Bazarr as
# native NixOS services (replaces the old Podman Quadlet units ported from
# rannoch's arrservice/docker-compose.yaml).
#
# Media access: the apps read/write /mnt/media (btrfs) through the `media`
# group. On first migration the directories must be setgid so new files keep
# the group:
#   chgrp -R media /mnt/media && chmod -R g+rwX /mnt/media \
#   && chmod g+s /mnt/media/{Downloads,Shows,Movies}
{ ... }:
{
  services = {
    qbittorrent = {
      enable = true;
      openFirewall = true;
      webuiPort = 8080;
      torrentingPort = 6881;
    };

    prowlarr = {
      enable = true;
      openFirewall = true;
    };

    sonarr = {
      enable = true;
      openFirewall = true;
    };

    radarr = {
      enable = true;
      openFirewall = true;
    };

    bazarr = {
      enable = true;
      openFirewall = true;
      listenPort = 6767;
    };
  };

  users = {
    groups.media = { };

    users = {
      tadeucruz.extraGroups = [ "media" ];
      qbittorrent.extraGroups = [ "media" ];
      sonarr.extraGroups = [ "media" ];
      radarr.extraGroups = [ "media" ];
      bazarr.extraGroups = [ "media" ];
    };
  };

  # qbittorrent's openFirewall only opens TCP; the torrenting port also needs UDP.
  networking.firewall.allowedUDPPorts = [ 6881 ];
}
