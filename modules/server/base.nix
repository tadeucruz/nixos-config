{
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [
    ../../modules/common/all.nix
    ../../modules/common/nix.nix
    ../services/avahi.nix
    ../services/openssh.nix
    ../services/tailscale.nix
    ../services/sonarr.nix
  ];

  boot = {
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };

  console.keyMap = lib.mkDefault "us-acentos";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };

  networking = {
    firewall.enable = true;
    networkmanager.enable = true;
  };

  programs.zsh.enable = true;

  users.users.${username} = {
    description = "Tadeu Cruz";
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB/cjwPFM4oVlrqYLY5LxeExIc/qPOH+AQzlPMeV+s9l"
    ];
    shell = pkgs.zsh;
  };

  zramSwap.enable = true;
}
