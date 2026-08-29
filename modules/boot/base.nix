{
  boot = {
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };
}
