# qBittorrent (omega) — BitTorrent client, native NixOS service. Ported from
# rannoch's arrservice/docker-compose.yaml.
{
  ...
}:
{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    webuiPort = 8080;
    torrentingPort = 6881;
  };

  users.users.qbittorrent.extraGroups = [ "media" ];

  # openFirewall only opens TCP; the torrenting port also needs UDP.
  networking.firewall.allowedUDPPorts = [ 6881 ];
}
