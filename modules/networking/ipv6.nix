{ lib, ... }:

{
  # IPv6 with RFC 7217 stable privacy addresses: a stable per-network
  # address that does not leak the MAC address (opposite of EUI-64).
  #
  # net.ipv6.conf.*.stable_secret (default = auto-generated from the
  # machine-id) turns SLAAC addr_gen_mode into "stable-privacy" (3). The
  # address is deterministic per (network prefix + secret), so it stays
  # fixed on a given network but differs across networks — ideal for both
  # desktops and the server.
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.addr_gen_mode" = 3;
    "net.ipv6.conf.default.addr_gen_mode" = 3;
  };

  # tmp.addr_gen_mode is applied per-interface so NetworkManager-managed
  # interfaces pick up the mode immediately on creation (the all/default
  # settings above seed new interfaces too).
  systemd.tmpfiles.rules = [
    "w /proc/sys/net/ipv6/conf/all/addr_gen_mode - - - - 3"
    "w /proc/sys/net/ipv6/conf/default/addr_gen_mode - - - - 3"
  ];
}
