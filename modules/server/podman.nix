# Podman + Quadlet (omega) — replaces the Docker Compose stacks. Quadlet turns
# each container into a systemd unit generated from /etc/containers/systemd.
#
# Quadlet is active by default on NixOS: podman ships podman-systemd-generator
# (wired via systemd.packages). There is no `virtualisation.quadlet` option on
# nixos-26.05, so quadlet units are declared with environment.etc.
#
# Migration path: `dockerCompat` + `dockerSocket` + `podman-compose` keep the
# existing compose files working as-is while services are ported one by one to
# quadlet units below (compose keys map 1:1).
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
