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

  # No ASPM overrides, BIOS defaults: the 2026-11-06 repro powered the box
  # off ~18s after a link flap even with ASPM off — fault is below the kernel.
}
