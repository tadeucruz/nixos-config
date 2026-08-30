{
  ...
}:
{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    webuiPort = 8080;
    torrentingPort = 6881;
    serverConfig = {
      Preferences = {
        WebUI = {
          Username = "tadeucruz";
          Password_PBKDF2 = "+L7ksybeqtQxqLs1DB+sQw==:672rPCXB61DTD+k/GYswh5skCTgZudInxmJoKW53UbhSmM7ZahswfkEsOiMiDt/F6vbRPlZPNishl0R6r3Tjlw==";
        };
        Downloads = {
          SavePath = "/mnt/data/Media/Downloads";
        };
      };
    };
  };

  users.users.qbittorrent.extraGroups = [ "media" ];

  networking.firewall.allowedUDPPorts = [ 6881 ];
}
