# Capture the next hang instead of guessing: lockup -> panic -> kdump vmcore
# -> auto-reboot. A hang wedged hard enough to kill the TCO pets (S5) stays
# dark, but a kernel-side lockup now leaves its stack in /var/crash.
{ ... }:
{
  boot.crashDump.enable = true;

  boot.kernelParams = [
    "panic=10"
    "softlockup_panic=1"
    "hardlockup_panic=1"
  ];
}