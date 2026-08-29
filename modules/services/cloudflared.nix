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
