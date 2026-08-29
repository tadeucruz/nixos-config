# Shared NixOS (Linux) config applied to citadel, prothean, and legion.
{
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [ ./all.nix ];

  boot = {
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "vm.max_map_count" = 2147483642;
    };
    kernelModules = [
      "ntsync"
      "tcp_bbr"
    ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    kernelParams = [
      "quiet"
      "splash"
    ];
    plymouth.enable = true;
  };

  console.keyMap = lib.mkDefault "us-acentos";

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };

  networking.networkmanager.enable = true;

  nix = {
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  nixpkgs.config.rocmSupport = true;

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

  security.rtkit.enable = true;

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

    flatpak = {
      enable = true;
      packages = [
        "com.bitwarden.desktop"
        "md.obsidian.Obsidian"
        "net.retrodeck.retrodeck"
      ];
    };

    fwupd.enable = true;

    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    pipewire = {
      alsa = {
        enable = true;
        support32Bit = true;
      };
      enable = true;
      pulse.enable = true;
    };

    syncthing = {
      enable = true;
      user = username;
      dataDir = "/home/${username}";
    };

    tailscale.enable = true;
  };

  # Mask to prevent DrKonqi's unbounded crash-loop when it can't find a display (KDE bug 524048, unfixed): https://bugs.kde.org/show_bug.cgi?id=524048
  systemd.user.sockets."drkonqi-coredump-launcher".enable = false;

  users.users.${username} = {
    description = "Tadeu Cruz";
    extraGroups = [
      "audio"
      "gamemode"
      "i2c"
      "input"
      "networkmanager"
      "uinput"
      "video"
      "wheel"
    ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB/cjwPFM4oVlrqYLY5LxeExIc/qPOH+AQzlPMeV+s9l"
    ];
    shell = pkgs.zsh;
  };

  zramSwap.enable = true;
}
