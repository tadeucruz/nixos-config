{
  ...
}:
{
  services.bazarr = {
    enable = true;
    openFirewall = true;
    listenPort = 6767;
  };

  users.users.bazarr.extraGroups = [ "media" ];
}
