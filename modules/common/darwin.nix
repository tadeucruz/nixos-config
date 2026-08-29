{ pkgs, username, ... }:
{
  imports = [ ./all.nix ];

  security.pam.services.sudo_local.touchIdAuth = true;

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

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
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };

    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = false;

    dock = {
      magnification = true;
      largesize = 128;
    };
  };
}
