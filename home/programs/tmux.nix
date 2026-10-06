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

    # Plugins (ordered: behaviour first, cosmetics last).
    #  - vim-tmux-navigator: hjkl crosses the vim <-> pane boundary
    #  - resurrect + continuum: manual + automatic session state save/restore
    #  - catppuccin: colour theme (mocha flavour)
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      resurrect
      continuum
      catppuccin
    ];

    extraConfig = ''
      # Copy to the system clipboard (works over ssh via OSC 52).
      set -g set-clipboard on

      # Catppuccin flavour for the plugin above.
      set -g @catppuccin_flavour 'mocha'

      # Hide the "current command" from the status bar — it leaks what you're
      # typing (zsh history, git commands, etc.). Keep hostname + session name.
      set -g status-left "[#{session_name}] "

      # Put the status bar at the top of the window (not the bottom).
      set -g status-position top
    '';
  };
}
