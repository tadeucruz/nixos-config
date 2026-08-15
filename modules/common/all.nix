# Shared config applied to ALL machines (cross-platform).
{ ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "pnpm-9.15.9" ];
  };

  time.timeZone = "America/Sao_Paulo";
}
