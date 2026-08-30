# Generic libvirt/KVM infrastructure (omega). Workload VMs (e.g. HAOS) live in
# modules/services/ and are defined on top of this.
{
  pkgs,
  username,
  ...
}:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
      };
    };
  };

  users.users.${username}.extraGroups = [ "libvirtd" ];
}
