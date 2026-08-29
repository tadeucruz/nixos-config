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

  networking.firewall.allowedUDPPorts = [ 6881 ];
}
