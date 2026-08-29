{
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [
    ../../modules/common/all.nix
    services/sonarr.nix
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

  nix = {
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  programs = {
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = "/home/${username}/nixos-config";
    };
    zsh.enable = true;
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        addresses = true;
        enable = true;
      };
    };

    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    tailscale.enable = true;
  };

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
