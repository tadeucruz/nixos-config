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
        # host/port are explicit because auto-detect binds the cache server on
        # the tailscale IP with a random port, which the host firewall drops
        # (jobs hit "Request timeout" on restore). Bind on the static br0 LAN IP
        # with a fixed port; port 5059 is opened in the firewall below — keep
        # both in sync.
        cache = {
          enabled = true;
          host = "192.168.0.2";
          port = 5059;
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
