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
      token = "3a912d00b3bb331482d4a43183c28ad2c6d97b02";
      labels = [ "ubuntu-latest:host" ];
      settings = {
        log.level = "info";
        runner.capacity = 1;
        runner.timeout = "3h";
      };
    };
  };
}
