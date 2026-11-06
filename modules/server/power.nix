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

  # pcie_aspm.policy=performance disables ASPM L1 globally: r8169 froze on
  # every link flap, even after dropping pcie_aspm=force (BIOS-enabled ASPM).
  boot.kernelParams = [ "pcie_aspm.policy=performance" ];
}
