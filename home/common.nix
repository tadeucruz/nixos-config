# Shared Home Manager config across all 3 machines.
{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  home = {
    enableNixpkgsReleaseCheck = false;
    homeDirectory = "/home/${username}";
    packages = with pkgs; [ ryzenadj ];
    sessionVariables = {
      SSH_AUTH_SOCK = "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock";
    };
    stateVersion = "26.05";
    inherit username;
  };

  # kbuildsycoca's incremental check misses store path hash changes on every rebuild, causing stale KDE plasmoid popups.
  home.activation.rebuildKdeSycoca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.getExe' pkgs.kdePackages.kservice "kbuildsycoca6"} --noincremental || true
  '';

  programs = {
    firefox = {
      enable = true;

      policies = {
        AppAutoUpdate = false;
        BackgroundAppUpdate = false;
        DisableTelemetry = true;
        DisablePocket = true;
        OfferToSaveLogins = false;

        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
            updates_disabled = true;
          };
        };
      };

      profiles.tadeucruz.search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";
      };
    };

    git = {
      enable = true;
      settings.user.name = "Tadeu Cruz";
      settings.user.email = "tadeucruz@gmail.com";
    };

    home-manager.enable = true;

    starship.enable = true;

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ll = "ls -alh";
        rebuild = "cd $NH_FLAKE && git pull && nh os switch";
        update = "cd $NH_FLAKE && git pull && nh os switch -u";
      };
    };
  };
}
