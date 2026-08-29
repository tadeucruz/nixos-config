# Sonarr (omega) — TV series manager, native NixOS service. Ported from
# rannoch's arrservice/docker-compose.yaml.
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
