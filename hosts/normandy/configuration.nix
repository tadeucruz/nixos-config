# nix-darwin configuration for the MacBook (normandy).
{ username, hostname, ... }:
{
  imports = [ ../../modules/common/darwin.nix ];

  networking.hostName = hostname;

  system.stateVersion = 7;
  system.primaryUser = username;
}
