{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    # Core: standard prefix, vi keys, mouse, sensible splits, generous scrollback.
    prefix = "C-b";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 100000;
    newSession = true;
    sensibleOnTop = true;

    # Plugins.
    #  - vim-tmux-navigator: hjkl crosses the vim <-> pane boundary
    #  - resurrect + continuum: manual + automatic session state save/restore
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      resurrect
      continuum
      dracula
    ];

    extraConfig = ''
      # Copy to the system clipboard (works over ssh via OSC 52).
      set -g set-clipboard on

      # Put the status bar at the top of the window (not the bottom).
      set -g status-position top

      # Dracula theme (https://draculatheme.com/tmux).
      # It owns status-left/status-right, so the old custom status-left was
      # removed — otherwise it would override the theme's left segment.
      set -g @dracula-show-powerline true
      set -g @dracula-show-left-icon session

      # Segment selection. Dracula's default is "battery network weather"; the
      # weather segment (scripts/weather.sh) curls https://wttr.in, which
      # geo-locates us by IP — and it re-runs every @dracula-refresh-rate (5s).
      # Keep only local, no-network segments.
      set -g @dracula-plugins "time uptime git cwd"
    '';
  };
}
