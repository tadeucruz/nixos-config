# FlareSolverr proxy (omega) — resolves Cloudflare challenges for Prowlarr.
# Native NixOS service (nixpkgs module, v3.5.0), no container needed.
# LAN access only via http://localhost:8191 — no openFirewall.
{
  ...
}:
{
  services.flaresolverr = {
    enable = true;
  };
}
