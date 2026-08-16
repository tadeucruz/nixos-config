# nix-darwin configuration for the MacBook (normandy).
{ username, hostname, ... }:
{
  imports = [
    ../../modules/common/darwin.nix
    ../../modules/normandy.nix
    ../../homebrew/common.nix
    ../../homebrew/normandy.nix
    ../../homebrew/development-mac.nix
  ];

  networking.hostName = hostname;

  system.stateVersion = 7;
  system.primaryUser = username;
}
