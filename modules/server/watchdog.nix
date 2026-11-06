# Arm the hardware watchdog so a hung kernel reboots itself instead of
# staying frozen until it is power-cycled by hand (omega has SP5100 TCO).
{ ... }:
{
  systemd.settings.Manager.RuntimeWatchdogSec = "30s";
}
