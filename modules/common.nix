# Shared config applied to ALL machines.
{ config, pkgs, lib, username, ... }:
{
  # --- Nix / flakes ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nixpkgs.config.allowUnfree = true;

  # --- Locale / timezone ---
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME     = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NUMERIC  = "pt_BR.UTF-8";
  };
  console.keyMap = "br-abnt2";

  # --- Networking ---
  networking.networkmanager.enable = true;

  # --- User ---
  users.users.${username} = {
    isNormalUser = true;
    description = "Tadeu Cruz";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "gamemode" "i2c" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB/cjwPFM4oVlrqYLY5LxeExIc/qPOH+AQzlPMeV+s9l"
    ];
  };
  programs.zsh.enable = true;

  # --- Bluetooth (controllers / headphones) ---
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # --- Audio (PipeWire) ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- Swap ---
  zramSwap.enable = true;

  # --- SSH ---
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
  ];
}
