{ pkgs, ... }:
let
  startThreshold = 75;
  endThreshold = 80;
in
{
  # smbios-battery-ctl for manual control: "smbios-battery-ctl
  # --set-charging-mode standard" charges to 100% (e.g. before travelling);
  # "smbios-battery-ctl --set-custom-charge-interval 75 80" re-applies the cap.
  environment.systemPackages = [ pkgs.libsmbios ];

  # The G15 stays plugged in most of the time — cap charging at 80% to slow
  # battery aging. The limit lives in firmware (same setting as Dell Power
  # Manager on Windows / BIOS "Battery charge configuration"), so it persists
  # across reboots; this oneshot is idempotent insurance after boot/CMOS reset.
  #
  # Prefer the kernel sysfs knobs (dell_laptop, kernel >= 6.12); fall back to
  # the Dell SMM interface when this BIOS does not expose them via sysfs.
  systemd.services.battery-charge-limit = {
    description = "Cap battery charging at ${toString endThreshold}%";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    path = [ pkgs.libsmbios ];
    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      applied=0
      for bat in /sys/class/power_supply/BAT*/; do
        if [ -e "$bat/charge_control_end_threshold" ]; then
          # Write start first (must stay below end for driver validation).
          if [ -e "$bat/charge_control_start_threshold" ]; then
            echo ${toString startThreshold} > "$bat/charge_control_start_threshold" || exit 1
          fi
          echo ${toString endThreshold} > "$bat/charge_control_end_threshold" || exit 1
          echo "sysfs: capped $bat at ${toString endThreshold}%"
          applied=1
        fi
      done

      # No sysfs support on this BIOS — go through Dell SMM (libsmbios) instead.
      if [ "$applied" -eq 0 ]; then
        smbios-battery-ctl --set-charging-mode custom || exit 1
        smbios-battery-ctl --set-custom-charge-interval ${toString startThreshold} ${toString endThreshold} || exit 1
      fi
    '';
  };
}
