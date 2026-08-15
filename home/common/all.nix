# Shared Home Manager config across all machines (cross-platform).
{
  username,
  ...
}:
{
  home = {
    enableNixpkgsReleaseCheck = false;
    stateVersion = "26.05";
    inherit username;
  };

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

      profiles.${username}.search = {
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
      };
    };
  };
}
