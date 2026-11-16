# VSCodium (VS Code without MS branding/telemetry) — native home-manager module.
# Dedicated `programs.vscodium` module (fork-aware paths); do NOT use
# `programs.vscode.package = pkgs.vscodium` — that writes VS Code's own paths.
# Linux only: normandy uses the Homebrew cask, which shares `~/.vscode-oss`, so
# extensions and settings carry over.
{ lib, pkgs, ... }:
{
  programs.vscodium.enable = !pkgs.stdenv.hostPlatform.isDarwin;
}
