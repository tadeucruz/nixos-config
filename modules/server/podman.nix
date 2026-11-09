# Podman + Quadlet (omega): replaces Docker Compose. Each workload is a systemd
# unit via environment.etc — NixOS has no `virtualisation.quadlet`, so podman's
# podman-systemd-generator declares them here.
{
  pkgs,
  ...
}:
{
  virtualisation = {
    podman = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      dockerCompat = true;
      dockerSocket.enable = true;
    };
  };

  systemd.services.podman-auto-update = {
    description = "Podman auto-update containers";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.podman}/bin/podman auto-update --rollback";
    };
    startAt = "weekly";
  };

  # Port each compose service to a quadlet unit here. Example:
  # environment.etc."containers/systemd/nginx.container".text = ''
  #   [Unit]
  #   Description=nginx
  #
  #   [Container]
  #   Image=docker.io/library/nginx:latest
  #   PublishPort=8080:80
  #   Volume=nginx-data:/usr/share/nginx/html
  #
  #   [Service]
  #   Restart=always
  # '';

  environment.systemPackages = [ pkgs.podman-compose ];
}
