# nix-darwin configuration for the MacBook (normandy).
{ username, ... }:
{
  imports = [ ../../modules/common/darwin.nix ];

  system.stateVersion = 7;
  system.primaryUser = username;
}
