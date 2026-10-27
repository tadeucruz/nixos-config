# Zed editor — native home-manager module.
# Config lives at ~/.config/zed on both Linux and macOS (Zed keeps the XDG
# path on darwin), so the same module works on prothean and normandy.
# nixpkgs has no `zed-editor-bin`, so normandy builds it from source (Rust +
# lld) on the first rebuild.
{
  programs.zed-editor.enable = true;
}
