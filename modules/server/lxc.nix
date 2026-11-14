# Generic LXC infrastructure (omega). Workload containers live in
# modules/services/ and are defined on top of this.
{
  pkgs,
  ...
}:
{
  virtualisation.lxc.enable = true;

  systemd.packages = [ pkgs.lxc ];

  systemd.services.lxc-net = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.iproute2
      pkgs.iptables
      pkgs.getent
      pkgs.dnsmasq
    ];
  };

  systemd.services.lxc = {
    enable = true;
    after = [ "lxc-net.service" ];
    requires = [ "lxc-net.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.lxc ];
  };
}
