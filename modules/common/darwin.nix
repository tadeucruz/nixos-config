# Shared nix-darwin (macOS) config (normandy).
{ pkgs, username, ... }:
{
  imports = [ ./all.nix ];

  homebrew = {
    enable = true;
    enableZshIntegration = true;
    onActivation.cleanup = "zap";
    brews = [ "displayplacer" ];
    casks = [ "iterm2" "cryptomator" ];
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

    dock = {
      magnification = true;
      largesize = 128;
      persistent-apps = [
        "/System/Cryptexes/App/System/Applications/Safari.app"
        "/Applications/iTerm.app"
        "/Users/${username}/Applications/Home Manager Apps/Visual Studio Code.app"
        "/System/Applications/Mail.app"
        "/System/Applications/Photos.app"
        "/System/Applications/Calendar.app"
        "/Users/${username}/Applications/Home Manager Apps/Obsidian.app"
        "/System/Applications/Reminders.app"
        "/System/Applications/Notes.app"
        "/System/Applications/TV.app"
        "/System/Applications/Music.app"
        "/System/Applications/System Settings.app"
      ];
    };
  };

  # macOS does not apply trackpad defaults until they are activated; without
  # this the switch writes the plists but tap-to-click stays off until
  # logout/login. Must run in the user's session (activation runs as root).
  system.activationScripts.postActivation.text = ''
    launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

    # Keep the built-in display on "More Space" (1800x1169) when it is
    # connected. Its persistent id changes between docks/reboots, so detect it
    # dynamically and skip silently when the lid is closed (external-only).
    # displayplacer must run in the user's session.
    builtin_id="$(
      launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- /opt/homebrew/bin/displayplacer list 2>/dev/null |
        awk '/^[[:space:]]*$/{id=""} /^Persistent screen id:/{id=$NF} /^Type:/ && $0 !~ /external/ && id != ""{print id; exit}'
    )"
    if [ -n "$builtin_id" ] && ! launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- /opt/homebrew/bin/displayplacer list 2>/dev/null | grep -q "res:1800x1169.*<-- current mode"; then
      launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- /opt/homebrew/bin/displayplacer "id:$builtin_id res:1800x1169 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" || true
    fi
  '';
}
