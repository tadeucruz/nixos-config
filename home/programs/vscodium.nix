# VSCodium (VS Code without MS branding/telemetry) — native home-manager module.
# Dedicated `programs.vscodium` module (fork-aware paths); do NOT use
# `programs.vscode.package = pkgs.vscodium` — that writes VS Code's own paths.
# nixpkgs ships prebuilt binaries for x86_64-linux and aarch64-darwin.
{
  programs.vscodium.enable = true;
}
