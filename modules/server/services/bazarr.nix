# Bazarr (omega) — subtitle manager, native NixOS service. Ported from
# rannoch's arrservice/docker-compose.yaml.
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
