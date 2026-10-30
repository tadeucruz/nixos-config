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

    # SteamOS defaults are tuned for the Steam Deck; only enable what makes
    # sense on this hardware. In particular, the default cmdline config
    # injects "amd_iommu=off", which would block EAC v2 requirement #5.
    steamos = {
      useSteamOSConfig = false;
      enableEarlyOOM = true;
    };
  };

  jovian.steam.desktopSession = config.desktop.sessionName;

  # Env for the Steam session. `home.sessionVariables` never reaches Steam here:
  # it is started by `steam-launcher.service`, outside the user session, so
  # gaming vars must be injected through Jovian (it wires them into the
  # service's EnvironmentFile).
  jovian.steam.environment = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      lib.makeSearchPathOutput "steamcompattool" ""
        config.programs.steam.extraCompatPackages;

    # Upgrade FSR 3.1 games to FSR 4. GE-Proton >= 11-2 does this automatically
    # on RDNA3/4, but keeping it explicit pins the behaviour and leaves the
    # RDNA3 path (needed on the 7900 and the Legion Go's Z1 Extreme) on.
    PROTON_FSR4_UPGRADE = "1";
    PROTON_FSR4_RDNA3_UPGRADE = "1";

    PROTON_USE_NTSYNC = "1";
  };

  # Jovian's autoStart runs its own SDDM (auto-login straight into the
  # gamescope-wayland session), so the desktop module's display manager must be
  # forced off — otherwise the DE and Jovian fight over the display manager.
  # The DE still provides the session Jovian switches to.
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
