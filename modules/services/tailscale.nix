{
  services.tailscale.enable = true;

  networking.firewall = {
    # Tailscale + firewall: avoid rp_filter drops (subnet routers, multi-interface).
    checkReversePath = "loose";
    # The tailnet is a private VPN — keep peers fully reachable (all NixOS hosts).
    trustedInterfaces = [ "tailscale0" ];
  };
}
