# Shared nix-darwin (macOS) config (normandy).
{ pkgs, username, ... }:
{
  imports = [ ./all.nix ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    brews = [ "displayplacer" ];
    casks = [ ];
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
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };
    # Keeps the System Settings trackpad UI in sync with the Clicking above.
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
  };

  # macOS does not apply trackpad defaults until they are activated; without
  # this the switch writes the plists but tap-to-click stays off until
  # logout/login. Must run in the user's session (activation runs as root).
  system.activationScripts.postActivation.text = ''
    launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

    # Keep the built-in display on "More Space" (1800x1169). displayplacer must
    # also run in the user's session; skip when already set to avoid flicker.
    if ! launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- /opt/homebrew/bin/displayplacer list 2>/dev/null | grep -q "res:1800x1169.*<-- current mode"; then
      launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- /opt/homebrew/bin/displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1800x1169 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"
    fi
  '';
}
