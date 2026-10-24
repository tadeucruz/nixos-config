{
  config,
  pkgs,
  lib,
  inputs,
  username,
  hostname,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common/all.nix
    ../../modules/common/nix.nix
    ../../modules/common/ghostty.nix
    ../../modules/common/locale.nix
    ../../modules/common/zsh.nix
    ../../modules/common/zram.nix
    ../../modules/boot/base.nix
    ../../modules/boot/eac-kexec.nix
    ../../modules/boot/eac-iommu.nix
    ../../modules/boot/gaming.nix
    ../../modules/security/tpm2.nix
    ../../modules/users/base.nix
    ../../modules/users/gaming.nix
    ../../modules/networking/networkmanager.nix
    ../../modules/networking/firewall.nix
    ../../modules/networking/dns.nix
    ../../modules/desktop/fonts.nix
    ../../modules/desktop/bluetooth.nix
    ../../modules/desktop/rtkit.nix
    ../../modules/desktop/rocm.nix
    ../../modules/desktop/kde.nix
    ../../modules/services/avahi.nix
    ../../modules/services/flatpak.nix
    ../../modules/services/fwupd.nix
    ../../modules/services/openssh.nix
    ../../modules/services/pipewire.nix
    ../../modules/services/syncthing.nix
    ../../modules/services/tailscale.nix
    ../../modules/gaming.nix
    ../../modules/btrfs-tuning.nix
    ../../modules/storage-health.nix
    ./stay-awake-ac.nix
    inputs.awcc.nixosModules.default
  ];

  boot = {
    # TODO(temp): acpi_call installs the module manually, bypassing
    # modules_install; the kernel-modules aggregator now requires a per-module
    # .cer for every external module. Install via modules_install until the fix
    # lands upstream, then revert to `[ acpi_call ]`.
    extraModulePackages = [
      (config.boot.kernelPackages.acpi_call.overrideAttrs (old: {
        makeFlags = old.makeFlags ++ [
          "INSTALL_MOD_PATH=${placeholder "out"}"
          "INSTALL_MOD_DIR=misc"
          "DEPMOD=true"
        ];
        installPhase = null;
        postInstall = ''
          install -D -m755 examples/turn_off_gpu.sh $out/bin/test_discrete_video_off.sh
        '';
      }))
    ];
    kernelModules = [ "acpi_call" ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  console.keyMap = "br-abnt2";

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;

      powerManagement.enable = true;
      powerManagement.finegrained = true; # powers off dGPU when idle (saves battery)

      prime = {
        amdgpuBusId = "PCI:116:0:0";
        nvidiaBusId = "PCI:1:0:0";

        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };
  };

  networking.hostName = hostname;

  services = {
    awcc.enable = true;

    hardware.openrgb.enable = true;

    printing.enable = true;

    xserver = {
      videoDrivers = [ "nvidia" ];
      xkb = {
        layout = "br";
        variant = "";
      };
    };
  };

  systemd.services.awccd.path = [
    "/run/wrappers"
    pkgs.polkit
  ];

  system.stateVersion = "26.05";
}
