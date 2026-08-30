# Forgejo (omega) — self-hosted git forge. TLS terminated by the Cloudflare
# Tunnel (ROOT_URL is https), LAN access over HTTP on :3001, built-in SSH on
# :2222 (doesn't touch the system sshd). The Actions runner lives in
# ./forgejo-runner.nix.
{ ... }:
{
  services.forgejo = {
    enable = true;
    settings = {
      server = {
        DOMAIN = "git.tadeucruz.com";
        SSH_DOMAIN = "omega.tail0a0fce.ts.net";
        ROOT_URL = "https://git.tadeucruz.com/";
        HTTP_PORT = 3001;
        SSH_PORT = 2222;
        START_SSH_SERVER = true;
      };
      service.DISABLE_REGISTRATION = true;
      actions = {
        # Actions is enabled by default since v1.21; explicit for clarity.
        ENABLED = true;
        # Resolve `uses:` from the Forgejo action mirrors (data.forgejo.org is
        # already the default in v16; pinned here to document the intent).
        DEFAULT_ACTIONS_URL = "https://data.forgejo.org";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    3001
    2222
  ];
}
