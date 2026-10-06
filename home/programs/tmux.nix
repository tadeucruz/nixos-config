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
    ];

    extraConfig = ''
      # Copy to the system clipboard (works over ssh via OSC 52).
      set -g set-clipboard on

      # Hide the "current command" from the status bar — it leaks what you're
      # typing (zsh history, git commands, etc.). Keep hostname + session name.
      set -g status-left "[#{session_name}] "

      # Put the status bar at the top of the window (not the bottom).
      set -g status-position top
    '';
  };
}
