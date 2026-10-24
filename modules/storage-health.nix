# Storage health for all NixOS hosts: SMART monitoring plus the tooling needed to
# inspect and update SSD/NVMe firmware.
#
# `smartd` auto-detects every drive and logs failures to the journal. The tools
# cover the manual side:
#   - smartctl / nvme-cli: SMART, error counters, `nvme fw-download`, ...
#   - unzip: Samsung's `fumagician` firmware updater shells out to `unzip` to
#     unpack the firmware archive, and NixOS ships no `unzip` by default.
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    smartmontools
    nvme-cli
    unzip
  ];

  services.smartd = {
    enable = true;
    autodetect = true;
    # Keep it quiet: findings go to the journal instead of wall/mail/X11 popups.
    notifications = {
      mail.enable = false;
      wall.enable = false;
      x11.enable = false;
    };
  };
}
