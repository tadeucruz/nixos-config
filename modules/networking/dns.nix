{
  # systemd-resolved: robust DNS that survives sleep/wake. Fixes Tailscale's
  # resolvconf-overwrite hijacking /etc/resolv.conf (it captured an empty
  # upstream list after wake on wired NICs -> SERVFAIL -> no DNS at all).
  # The resolved module auto-sets networking.networkmanager.dns =
  # "systemd-resolved" and networking.resolvconf.enable = false, so Tailscale
  # integrates via D-Bus per-interface instead of overwriting resolv.conf.
  # networking.nameservers stays unset on DHCP hosts (per-link DNS wins).
  services.resolved.enable = true;
}
