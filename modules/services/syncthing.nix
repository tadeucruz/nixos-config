{
  username,
  ...
}:
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = username;
    dataDir = "/home/${username}";

    # Declarative hub-and-spoke: desktops only ever talk to the central hub
    # (omega), never to each other. Declaring `settings` makes the repo the
    # source of truth — `overrideDevices`/`overrideFolders` default to true,
    # so anything added by hand (GUI/CLI) is wiped on the next boot.
    #
    # The device IDs are public (a SHA-256 fingerprint of the peer's cert) and
    # are announced to discovery/relay servers anyway — safe to keep in git.
    # The local device is implicit: Syncthing adds itself to every folder.
    settings = {
      devices.omega = {
        id = "NM4A6PJ-U6D2TR3-EG4UGVS-KRGZSUF-KUWJ5AP-PWR4KV5-ODHV2M2-OT6SEAI";
        # Optional but useful off-LAN (laptop/handheld): talk to the hub
        # directly over tailscale instead of falling back to a relay.
        addresses = [
          "dynamic"
          "tcp://omega.tail0a0fce.ts.net:22000"
        ];
      };

      # Folder id must match the one already shared by the hub.
      folders.Wallpapers = {
        id = "xifdn-zyhbo";
        label = "Wallpapers";
        path = "/home/${username}/Pictures/Wallpapers";
        devices = [ "omega" ];
      };
    };
  };
}
