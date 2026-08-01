# Shared config applied to ALL machines.
{ config, pkgs, lib, username, ... }:
{
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Lets this user's machine push locally-built (unsigned) closures to this host
  # over SSH for remote deploys (nixos-rebuild --target-host), e.g. building on
  # citadel and deploying to legion.
  nix.settings.trusted-users = [ "root" username ];
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME     = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NUMERIC  = "pt_BR.UTF-8";
  };
  console.keyMap = lib.mkDefault "us-acentos";

  networking.networkmanager.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    description = "Tadeu Cruz";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "gamemode" "i2c" "input" "uinput" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB/cjwPFM4oVlrqYLY5LxeExIc/qPOH+AQzlPMeV+s9l"
    ];
  };
  programs.zsh.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  zramSwap.enable = true;

  services.openssh.enable = true;

  # reach machines as <hostname>.local
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.fwupd.enable = true;

  hardware.cpu.amd.ryzen-smu.enable = lib.mkDefault true;

  boot.plymouth.enable = true;
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [ "quiet" "splash" ];

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    btop
  ];
}
