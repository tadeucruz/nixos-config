# Packages only available on nixos-unstable (desktop hosts only).
# herdr 0.9.3+ builds cleanly on x86_64-linux — the 0.9.1 RUSTFLAGS
# workaround (--no-eh-frame-hdr) is gone.
{ pkgs, ... }:
{
  home.packages = [ pkgs.herdr ];
}
