{
  lib,
  options,
  ...
}:
let
  # nixpkgs 26.11 replaced `services.resolved.extraConfig` with the freeform
  # `services.resolved.settings`; omega (stable 26.05) still uses the old one,
  # so pick whichever the running nixpkgs exposes.
  hasSettings = options.services.resolved ? settings;
in
{
  services.resolved = {
    # systemd-resolved: robust DNS that survives sleep/wake. Fixes Tailscale's
    # resolvconf-overwrite hijacking /etc/resolv.conf (it captured an empty
    # upstream list after wake on wired NICs -> SERVFAIL -> no DNS at all).
    # The resolved module auto-sets networking.networkmanager.dns =
    # "systemd-resolved" and networking.resolvconf.enable = false, so Tailscale
    # integrates via D-Bus per-interface instead of overwriting resolv.conf.
    # networking.nameservers stays unset on DHCP hosts (per-link DNS wins).
    enable = true;
  }
  // lib.optionalAttrs hasSettings {
    # Avahi is the sole mDNS responder: resolved's mDNS fights over the
    # hostname (avahi climbed to omega-114.local, breaking SMB discovery).
    settings.Resolve.MulticastDNS = "no";
  }
  // lib.optionalAttrs (!hasSettings) {
    extraConfig = "MulticastDNS=no";
  };
}
