# Forgejo Actions runner (omega) — nixpkgs `services.gitea-actions-runner`
{
  pkgs,
  ...
}:
{
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.default = {
      enable = true;
      name = "omega-runner";
      url = "http://127.0.0.1:3001";
      secrets.server.connections.default.token_url = "file:///etc/forgejo-runner/token";
      labels = [ "ubuntu-latest:host" ];
      settings = {
        log.level = "info";
        runner.capacity = 1;
        runner.timeout = "3h";

        server.connections.default.uuid = "2a170415-a2d1-4054-a79e-ce2f3d90476f";
      };
    };
  };
}
