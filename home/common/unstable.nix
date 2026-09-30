{ pkgs, ... }:
let
  # herdr 0.9.1 (nixpkgs) statically links the zig-built libghostty-vt.a, whose
  # .eh_frame carries overlapping FDEs that binutils >= 2.44's ld.bfd rejects
  # ("ld.bfd: .eh_frame_hdr refers to overlapping FDEs"), so it fails to build
  # on x86_64-linux. Skipping the .eh_frame_hdr index keeps unwinding working
  # via the full .eh_frame. Remove once nixpkgs bumps herdr past the broken 0.9.1.
  herdr =
    if pkgs.stdenv.isLinux then
      pkgs.herdr.overrideAttrs (old: {
        env = (old.env or { }) // {
          RUSTFLAGS = (old.env.RUSTFLAGS or "") + " -C link-arg=-Wl,--no-eh-frame-hdr";
        };
      })
    else
      pkgs.herdr;
in
{
  home.packages = [ herdr ];
}
