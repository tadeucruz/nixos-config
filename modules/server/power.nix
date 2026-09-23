# Idle power tuning for omega (24/7 mini-PC server, SSDs only).
{
  lib,
  ...
}:
{
  powerManagement = {
    cpuFreqGovernor = lib.mkDefault "powersave";
    powertop.enable = true;
  };

  boot.kernelParams = [ "pcie_aspm=force" ];
}
