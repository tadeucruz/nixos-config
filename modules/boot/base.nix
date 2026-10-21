{
  boot = {
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };

  # All firmware blobs, including non-redistributable ones (implies
  # enableRedistributableFirmware, which also drives updateMicrocode in the
  # generated hardware-configuration.nix).
  hardware.enableAllFirmware = true;
}
