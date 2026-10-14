{
  boot = {
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
    kernelParams = [
      "amd_iommu=on"
      "lockdown=integrity"
      "kexec_load_disabled=1"
      "lsm=lockdown,yama,loadpin,safesetid,integrity,apparmor,bpf"
    ];
    kernelModules = [ "bpf" ];
  };
}
