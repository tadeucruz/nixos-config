# Dev toolchain (languages + editors) — prothean + normandy only.
# The editor modules gate themselves off on darwin: normandy gets Zed/VSCodium
# from the Homebrew casks (homebrew/normandy.nix) so their own updaters work.
{
  imports = [
    ./programs/go.nix
    ./programs/java.nix
    ./programs/nodejs.nix
    ./programs/nixd.nix
    ./programs/vscodium.nix
    ./programs/zed.nix
  ];
}
