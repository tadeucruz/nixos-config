{ lib, options, ... }:
let
  # nixpkgs 26.11 replaced the old `services.avahi.publish.*` options with the
  # freeform `services.avahi.settings`; omega (stable 26.05) still uses the old
  # ones, so pick whichever the running nixpkgs exposes.
  hasSettings = options.services.avahi ? settings;
in
{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  }
  // lib.optionalAttrs hasSettings {
    settings.publish = {
      "disable-publishing" = false;
      "publish-addresses" = true;
    };
  }
  // lib.optionalAttrs (!hasSettings) {
    publish = {
      enable = true;
      addresses = true;
    };
  };
}
