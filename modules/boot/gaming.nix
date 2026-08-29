{
  pkgs,
  lib,
  ...
}:
{
  boot = {
    kernel.sysctl."vm.max_map_count" = 2147483642;
    kernelModules = [
      "ntsync"
      "tcp_bbr"
    ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    kernelParams = [
      "quiet"
      "splash"
    ];
    plymouth.enable = true;
  };
}
