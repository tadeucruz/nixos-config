# EAC v2 requirement #6: kernel lockdown integrity.
# Available since nixpkgs unstable enabled CONFIG_SECURITY_LOCKDOWN_LSM +
# CONFIG_MODULE_SIG (deterministic per-module certs via kmodigest) — verified
# 2026-10-31 on citadel (OGC 7.2.11) and prothean (7.3.0). Not available on
# nixos-26.05 (stable, omega) — see epic.md.
{
  boot.kernelParams = [ "lockdown=integrity" ];
}
