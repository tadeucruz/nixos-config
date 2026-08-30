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
          Password_PBKDF2 = "PBKDF2@100000:sha512:2716154e31262555d87f8db522fbd601:3bff83a8c12eb1fc91f3693b38cb2cb494ec11b15bbd557b4eb4a422613da2fb335b87dab9788ffc9104309e7997f4699751dd940b076d55b20a589da6dec689";
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
