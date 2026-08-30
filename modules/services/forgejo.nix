# Forgejo (omega) — self-hosted git forge. TLS terminated by the Cloudflare
# Tunnel (ROOT_URL is https), LAN access over HTTP on :3001, built-in SSH on
# :2222 (doesn't touch the system sshd).
{
  pkgs,
  ...
}:
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

  # Forgejo Actions runner — runs jobs natively on the host (`:host` label),
  # no container runtime needed. Registration token (one-time use) goes in
  # /etc/forgejo-runner/token as `TOKEN=...`, outside git (same pattern as the
  # cloudflared token). The `gitea-actions-runner` module also serves Forgejo;
  # using its native package (the module predates forgejo-runner v12, which
  # dropped the `register` flow in favour of server.connections).
  services.gitea-actions-runner = {
    package = pkgs.gitea-actions-runner;
    instances.forgejo = {
      enable = true;
      name = "forgejo";
      url = "http://127.0.0.1:3001";
      tokenFile = "/etc/forgejo-runner/token";
      labels = [ "ubuntu-latest:host" ];
      # Native host execution: jobs only see coreutils + these. nix is what
      # `make check`/update.sh need; gnumake for the Makefile; python3 for
      # update.sh's pin rewriting.
      hostPackages = [
        pkgs.nix
        pkgs.gnumake
        pkgs.python3
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    3001
    2222
  ];
}
