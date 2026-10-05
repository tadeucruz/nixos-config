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
        # job containers reuse fetched nix inputs across runs instead of
        # re-downloading. Already the upstream default; pinned so upgrades can't
        # regress it. Blobs persist in /var/lib/gitea-runner/<name>/.cache/actcache.
        #
        # ACTIONS_CACHE_URL points job containers at a one-shot cache proxy; its
        # host/port come from cache.host/cache.proxy_port (both random by
        # default). cache.host is the static br0 LAN IP, confirmed reachable from
        # real job containers via the cache-diag run (avoiding tailscale). The
        # proxy_port MUST be pinned so the host firewall can allow it — port 5059
        # is opened below, keep both in sync. The proxy authenticates with a
        # per-job secret, so LAN exposure is safe. The internal backend
        # (cache.port) stays random and only the proxy talks to it locally.
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
