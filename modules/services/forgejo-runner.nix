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
        # Serve actions/cache (data.forgejo.org/actions/cache) so the ephemeral
        # docker jobs reuse fetched nix inputs across runs instead of re-downloading.
        # Already the upstream default; pinned so upgrades can't regress it.
        # Blobs persist in /var/lib/gitea-runner/<name>/.cache/actcache on omega.
        cache.enabled = true;
        # Always pull `:latest` before a job: the runner otherwise reuses the
        # already-downloaded image and never picks up rebuilt images (e.g. the
        # nix-ci-builder with make/python3).
        container.force_pull = true;
      };
    };
  };
}
