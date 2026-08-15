# Shared nix-darwin (macOS) config (normandy).
{ pkgs, username, ... }:
{
  imports = [ ./all.nix ];

  nix.settings.trusted-users = [ "root" username ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      "bitwarden"
      "betterdisplay"
    ];
  };

  services.tailscale.enable = true;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  launchd.user.agents.syncthing = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.syncthing}/bin/syncthing"
        "serve"
        "--no-browser"
        "--no-restart"
        "--no-upgrade"
      ];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
    };

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
    };
  };
}
