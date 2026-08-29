# Prowlarr (omega) — indexer manager, native NixOS service. Ported from
# rannoch's arrservice/docker-compose.yaml. Keeps its DynamicUser (no media
# access needed).
{
  ...
}:
{
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
}
