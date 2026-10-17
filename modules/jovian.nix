# Applied to citadel and legion.
{
  config,
  lib,
  pkgs,
  username,
  ...
}:
{
  jovian = {
    decky-loader.enable = true;

    hardware.has.amd.gpu = true;

    steam = {
      autoStart = true;
      enable = true;
      user = username;
    };

    steamos = {
      useSteamOSConfig = true;

      # Jovian's default cmdline includes "amd_iommu=off", which takes
      # precedence over "iommu=on" and blocks EAC v2 requirement #5. Keep the
      # rest of the SteamOS tuning below, but drop the IOMMU flag.
      enableDefaultCmdlineConfig = false;
    };
  };

  # Copied from Jovian's modules/steamos/boot.nix (SteamOS cmdline flags),
  # minus "amd_iommu=off". Re-sync this list when bumping the jovian input:
  # https://github.com/Jovian-Experiments/Jovian-NixOS/blob/master/modules/steamos/boot.nix
  boot.kernelParams = [
    "log_buf_len=4M"
    "amdgpu.lockup_timeout=5000,10000,10000,5000"
    "ttm.pages_min=2097152"
    "amdgpu.sched_hw_submission=4"
    "amdgpu.dcdebugmask=0x20000"
    "audit=0"
  ];

  jovian.steam.desktopSession = config.desktop.sessionName;

  jovian.steam.environment.STEAM_EXTRA_COMPAT_TOOLS_PATHS =
    lib.makeSearchPathOutput "steamcompattool" ""
      config.programs.steam.extraCompatPackages;

  services = {
    displayManager.plasma-login-manager.enable = lib.mkForce false;
    xserver.enable = false;
  };

  systemd.services.steam-cef-debug = lib.mkIf config.jovian.decky-loader.enable {
    description = "Create Steam CEF debugging file";
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/sh -c 'mkdir -p ~/.steam/steam && [ ! -f ~/.steam/steam/.cef-enable-remote-debugging ] && touch ~/.steam/steam/.cef-enable-remote-debugging || true'";
      Type = "oneshot";
      User = config.jovian.steam.user;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
