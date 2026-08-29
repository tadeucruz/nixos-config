# Cloudflare Tunnel (omega) — remote access. The tunnel is remotely managed
# (token-based, like the previous cloudflared LXC), so nixpkgs'
# services.cloudflared.tunnels (credentials-file based) doesn't apply; a
# minimal systemd service runs `cloudflared tunnel run` with TUNNEL_TOKEN.
#
# Setup: create /etc/cloudflared/token with the line `TUNNEL_TOKEN=<token>`
# (outside this repo, not in git).
{
  pkgs,
  ...
}:
{
  systemd.services.cloudflared = {
    description = "Cloudflare Tunnel client (remotely managed)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run";
      EnvironmentFile = "/etc/cloudflared/token";
      DynamicUser = true;
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
