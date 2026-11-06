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

  # No pcie_aspm=force: forced ASPM hangs r8169 on link flap (omega froze on router reboots).
}
