{
  inputs,
  pkgs,
  ...
}:
{
  # `pinned` overlay: kernel built against the nix-cachyos-kernel repo's own
  # nixpkgs revision, which is what its Hydra publishes — guaranteed binary
  # cache hits, no local kernel compilation.
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  # Author's attic cache (the release branch's kernels are all prebuilt here).
  nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
  nix.settings.extra-trusted-public-keys = [
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
  ];
}
