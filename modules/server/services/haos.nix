# HAOS VM (omega) — Home Assistant OS must run as a VM (appliance). The qcow2
# image is pinned via fetchurl and decompressed on first boot; the libvirt
# domain is defined declaratively from the XML in this repo. Requires the
# generic libvirt module (modules/server/libvirt.nix).
#
# The haos-vm service is idempotent: the qcow2 (which holds all HAOS configs)
# is only decompressed once, and `virsh define` only applies the hardware
# definition (RAM/CPU/disk), never destroying or recreating the VM.
#
# TODO:
# - pin haosVersion to the version currently running on Proxmox and fill sha256
#   (`nix-prefetch-url <url>`)
# - create the br0 bridge on the host (e.g. networking.bridges.br0) so HAOS is
#   reachable on the LAN, or switch the XML to a NAT network
{
  config,
  pkgs,
  ...
}:
let
  haosVersion = "13.2"; # TODO: pin to the version currently running on Proxmox
  haosImage = pkgs.fetchurl {
    url = "https://github.com/home-assistant/operating-system/releases/download/${haosVersion}/haos_ova-${haosVersion}.qcow2.xz";
    sha256 = ""; # TODO: fill via `nix-prefetch-url <url>` after picking haosVersion
  };
in
{
  assertions = [
    {
      assertion = config.virtualisation.libvirtd.enable;
      message = "services/haos.nix requires modules/server/libvirt.nix (virtualisation.libvirtd.enable)";
    }
  ];

  environment.etc."libvirt/qemu/haos.xml".text = ''
    <domain type='kvm'>
      <name>haos</name>
      <memory unit='GiB'>4</memory>
      <vcpu>4</vcpu>
      <os>
        <type arch='x86_64'>hvm</type>
        <boot dev='hd'/>
      </os>
      <features>
        <acpi/>
        <apic/>
      </features>
      <devices>
        <disk type='file' device='disk'>
          <driver name='qemu' type='qcow2'/>
          <source file='/var/lib/libvirt/images/haos.qcow2'/>
          <target dev='vda' bus='virtio'/>
        </disk>
        <interface type='bridge'>
          <source bridge='br0'/>
          <model type='virtio'/>
        </interface>
        <video>
          <model type='virtio'/>
        </video>
      </devices>
    </domain>
  '';

  systemd.services.haos-vm = {
    description = "Set up HAOS VM image and libvirt domain";
    wantedBy = [ "multi-user.target" ];
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu
      mkdir -p /var/lib/libvirt/images
      image=/var/lib/libvirt/images/haos.qcow2
      if [ ! -f "$image" ]; then
        ${pkgs.xz}/bin/xz -dkc ${haosImage} > "$image"
      fi
      chown qemu-libvirtd:qemu-libvirtd "$image"
      ${pkgs.libvirt}/bin/virsh define /etc/libvirt/qemu/haos.xml
      ${pkgs.libvirt}/bin/virsh autostart haos
    '';
  };
}
