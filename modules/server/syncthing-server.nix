{
  username,
  ...
}:
{
  services.syncthing = {
    enable = true;
    user = "syncthing";
    group = "syncthing";
    dataDir = "/var/lib/syncthing";
    guiAddress = "0.0.0.0:8384";
    openDefaultPorts = true;
    overrideDevices = false;
    overrideFolders = false;
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];

  systemd.tmpfiles.rules = [ "d /mnt/data/Sync 2770 syncthing syncthing - -" ];

  users.users.${username}.extraGroups = [ "syncthing" ];
}
