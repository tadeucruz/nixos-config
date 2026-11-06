# Arm the hardware watchdog so a hung kernel reboots itself instead of
# staying frozen until it is power-cycled by hand (omega has SP5100 TCO).
# 45s: one notch above the 30s BIOS watchdog — pre-boot hangs are caught
# by the BIOS at 30s, runtime hangs by systemd at 45s (same TCO timer).
{ ... }:
{
  systemd.settings.Manager.RuntimeWatchdogSec = "45s";
}
