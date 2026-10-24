{ pkgs, ... }:
{
  # smbios-battery-ctl for manual control: "smbios-battery-ctl
  # --set-charging-mode standard" charges to 100% (e.g. before travelling);
  # "smbios-battery-ctl --set-charging-mode primarily_ac" re-applies this profile.
  environment.systemPackages = [ pkgs.libsmbios ];

  # The G15 stays plugged in most of the time, so use Dell's "Primarily AC Use"
  # profile (Dell Power Manager on Windows / BIOS "Battery charge configuration"
  # -> Primarily AC), which lowers the charge target to slow battery aging
  # instead of holding it at 100%.
  #
  # This model exposes no charge_control_* sysfs knobs (dell_laptop), so go
  # through the Dell SMM interface (libsmbios). The setting lives in firmware,
  # so it persists across reboots; this oneshot is idempotent insurance after
  # boot / CMOS reset.
  systemd.services.battery-charge-limit = {
    description = "Apply Dell 'Primarily AC Use' battery charging profile";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    path = [ pkgs.libsmbios ];
    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      smbios-battery-ctl --set-charging-mode primarily_ac || exit 1
      echo "primarily_ac charging mode applied"
    '';
  };
}
