# Forgejo (omega) — self-hosted git forge. TLS terminated by the Cloudflare
# Tunnel (ROOT_URL is https), LAN access over HTTP on :3001, built-in SSH on
# :2222 (doesn't touch the system sshd).
{ ... }:
{
  services.forgejo = {
    enable = true;
    settings = {
      server = {
        DOMAIN = "git.tadeucruz.com";
        ROOT_URL = "https://git.tadeucruz.com/";
        HTTP_PORT = 3001;
        SSH_PORT = 2222;
        START_SSH_SERVER = true;
      };
      service.DISABLE_REGISTRATION = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    3001
    2222
  ];
}
