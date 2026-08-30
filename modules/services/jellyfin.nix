{ ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    hardwareAcceleration = {
      enable = true;
      device = "/dev/dri/renderD128";
      type = "vaapi";
    };
  };

  users.users.jellyfin.extraGroups = [ "media" ];
}
