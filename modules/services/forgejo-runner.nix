# Forgejo Actions runner (omega) — forgejo-runner v12 daemon.
#
# Runs jobs natively on the host (`ubuntu-latest:host` label), no container
# runtime needed. The v12 runner dropped the legacy `register` flow in favour
# of `server.connections` (UUID + token from the "Create new runner" UI flow).
#
# The token stays outside git: systemd reads it as root and exposes it to the
# DynamicUser via $CREDENTIALS_DIRECTORY (LoadCredential), and the config
# references it with token_url. Only the UUID is baked into the nix config.
{
  pkgs,
  ...
}:
let
  runnerConfig = (pkgs.formats.yaml { }).generate "forgejo-runner.yaml" {
    log.level = "info";
    runner = {
      capacity = 1;
      timeout = "3h";
      labels = [ "ubuntu-latest:host" ];
    };
    server.connections.forgejo = {
      url = "http://127.0.0.1:3001";
      uuid = "2a170415-a2d1-4054-a79e-ce2f3d90476f";
      token_url = "file:$CREDENTIALS_DIRECTORY/token";
    };
  };
in
{
  systemd.services.forgejo-runner = {
    description = "Forgejo Actions runner";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.forgejo-runner}/bin/forgejo-runner daemon --config ${runnerConfig}";
      DynamicUser = true;
      StateDirectory = "forgejo-runner";
      WorkingDirectory = "-/var/lib/forgejo-runner";
      Environment = [ "HOME=/var/lib/forgejo-runner" ];
      LoadCredential = "token:/etc/forgejo-runner/token";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}