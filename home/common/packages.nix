{ pkgs, inputs, ... }:
{
  home.packages =
    with pkgs;
    [
      btop
      curl
      ripgrep
      vim
      wget
      gnumake
    ]
    ++ [ inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
