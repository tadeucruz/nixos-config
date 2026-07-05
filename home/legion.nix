{ pkgs, ... }:
{
  imports = [ ./common.nix ./jovian.nix ];

  home.packages = with pkgs; [ claude-code ];
}
