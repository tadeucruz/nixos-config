{ ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  security.sudo.extraConfig = "Defaults passwd_timeout=0";

  time.timeZone = "America/Sao_Paulo";
}
