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
      url = "https://git.tadeucruz.com";
      tokenFile = "/etc/forgejo-runner/token";
      labels = [
        "nix:docker://git.tadeucruz.com/tadeucruz/nix-ci-builder:latest"
        "debian-latest:docker://node:current-trixie"
        "buildah:docker://quay.io/containers/buildah:latest"
      ];
      settings = {
        log.level = "info";
        runner.capacity = 2;
        runner.timeout = "3h";
        # One-shot cache proxy for ephemeral job containers; keeps actions/cache
        # across runs. pin proxy_port — the host firewall allows it (5059 below);
        # a random value would drop every request.
        cache = {
          enabled = true;
          host = "192.168.0.2";
          proxy_port = 5059;
        };
        # Always pull `:latest` before a job: the runner otherwise reuses the
        # already-downloaded image and never picks up rebuilt images (e.g. the
        # nix-ci-builder with make/python3).
        container.force_pull = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 5059 ];
}
