# Dock layout and activation scripts specific to normandy's physical hardware
# and personal app choices — not dev tooling, just this one machine.
# (Homebrew casks/brews/masApps live in homebrew/development-mac.nix instead.)
{ username, ... }:
{
  system.defaults.dock.persistent-apps = [
    "/System/Cryptexes/App/System/Applications/Safari.app"
    "/System/Applications/Utilities/Terminal.app"
    "/Users/${username}/Applications/Home Manager Apps/Visual Studio Code.app"
    "/System/Applications/Mail.app"
    "/System/Applications/Photos.app"
    "/System/Applications/Calendar.app"
    "/Users/${username}/Applications/Home Manager Apps/Obsidian.app"
    "/System/Applications/Reminders.app"
    "/System/Applications/Notes.app"
    "/System/Applications/TV.app"
    "/System/Applications/Music.app"
    "/System/Applications/Podcasts.app"
    "/Applications/WhatsApp.app"
    "/System/Applications/System Settings.app"
  ];

  system.activationScripts.postActivation.text = ''
    # Keep the built-in display on "More Space" (1800x1169) when it is
    # connected. Its persistent id changes between docks/reboots, so detect it
    # dynamically and skip silently when the lid is closed (external-only).
    # displayplacer must run in the user's session.
    builtin_id="$(
      launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- /opt/homebrew/bin/displayplacer list 2>/dev/null |
        awk '/^[[:space:]]*$/{id=""} /^Persistent screen id:/{id=$NF} /^Type:/ && $0 !~ /external/ && id != ""{print id; exit}'
    )"
    if [ -n "$builtin_id" ] && ! launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- /opt/homebrew/bin/displayplacer list 2>/dev/null | grep -q "res:1800x1169.*<-- current mode"; then
      launchctl asuser "$(id -u -- ${username})" sudo --user=${username} -- /opt/homebrew/bin/displayplacer "id:$builtin_id res:1800x1169 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" \
        || echo "postActivation: displayplacer failed to set built-in display mode" >> /tmp/darwin-activation.log
    fi
  '';
}
