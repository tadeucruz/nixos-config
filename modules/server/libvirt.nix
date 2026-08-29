# Generic libvirt/KVM infrastructure (omega). Workload VMs (e.g. HAOS) live in
# modules/services/ and are defined on top of this.
{
  pkgs,
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

  environment.systemPackages = [ pkgs.virt-manager ];
}
