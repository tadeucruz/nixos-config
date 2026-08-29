{
  ...
}:
{
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  users.users.sonarr.extraGroups = [ "media" ];
}
