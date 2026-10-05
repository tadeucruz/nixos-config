{ username, hostname, ... }:
{
  imports = [
    ../../modules/common/darwin.nix
    ../../modules/darwin/xcode.nix
    ../../modules/normandy.nix
    ../../homebrew/common.nix
    ../../homebrew/normandy.nix
    ../../homebrew/development.nix
  ];

  networking.hostName = hostname;

  system.stateVersion = 7;
  system.primaryUser = username;
}
