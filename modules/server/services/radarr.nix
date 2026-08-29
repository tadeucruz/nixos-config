# Radarr (omega) — movie manager, native NixOS service. Ported from rannoch's
# arrservice/docker-compose.yaml.
{
  ...
}:
{
  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  users.users.radarr.extraGroups = [ "media" ];
}
