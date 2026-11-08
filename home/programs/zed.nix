# Zed editor — native home-manager module.
# Config lives at ~/.config/zed on both Linux and macOS (Zed keeps the XDG
# path on darwin), so the same module works on prothean and normandy.
# nixpkgs has no `zed-editor-bin`, so normandy builds it from source (Rust +
# lld) on the first rebuild.
{ pkgs, ... }:
let
  # cargoSetupHook forces AWS_LC_SYS_USE_SYSTEM=1, but cargo-bundle (a Darwin
  # build input of zed) doesn't pull aws-lc, so its aws-lc-sys dep panics.
  # Mirrors nixpkgs PR #584581 (tracking issue #570938) — drop once merged.
  cargo-bundle = pkgs.cargo-bundle.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.pkg-config ];
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.aws-lc ];
  });
in
{
  programs.zed-editor = {
    enable = true;
    # Linux gets the cached zed-editor; only Darwin needs the patched build.
    package =
      if pkgs.stdenv.hostPlatform.isDarwin then
        pkgs.zed-editor.override { inherit cargo-bundle; }
      else
        pkgs.zed-editor;
  };
}
