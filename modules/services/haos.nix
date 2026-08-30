{
  config,
  pkgs,
  ...
}:
let
  haosVersion = "18.2";
  haosImage = pkgs.fetchurl {
    url = "https://github.com/home-assistant/operating-system/releases/download/${haosVersion}/haos_ova-${haosVersion}.qcow2.xz";
    sha256 = "0ki59x2mqrjg822khw3bvzq57pq7391yb6y0mzikj1yzakrm6ki5";
  };
in
{
  assertions = [
    {
      assertion = config.virtualisation.libvirtd.enable;
      message = "modules/services/haos.nix requires modules/server/libvirt.nix (virtualisation.libvirtd.enable)";
    }
  ];

  environment.etc."libvirt/qemu/haos.xml".text = ''
    <domain type='kvm'>
      <name>haos</name>
      <uuid>fd42671f-5507-4ae5-ae91-f333557a2d4e</uuid>
      <memory unit='GiB'>4</memory>
      <vcpu>4</vcpu>
      <os firmware='efi'>
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
          <target dev='sda' bus='sata'/>
          <boot order='1'/>
        </disk>
        <interface type='bridge'>
          <source bridge='br0'/>
          <model type='virtio'/>
        </interface>
        <serial type='pty'>
          <target port='0'/>
        </serial>
        <console type='pty'>
          <target type='serial' port='0'/>
        </console>
        <graphics type='vnc' port='-1' autoport='yes' listen='127.0.0.1' passwd='eaaf418d4e2b'>
          <listen type='address' address='127.0.0.1'/>
        </graphics>
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
