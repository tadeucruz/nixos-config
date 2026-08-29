# Firefox policies + default search — desktop machines only (not servers).
{ username, ... }:
{
  programs.firefox = {
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
        };
      };
    };

    profiles.${username}.search = {
      force = true;
      default = "ddg";
      privateDefault = "ddg";
    };
  };
}
