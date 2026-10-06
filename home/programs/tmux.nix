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
    #  - dracula: theme (owns status-left/status-right)
    #  - resurrect + continuum: manual + automatic session state save/restore
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-show-powerline true
          set -g @dracula-show-left-icon session
          set -g @dracula-plugins "time git cwd"
        '';
      }
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set-hook -g client-detached 'run-shell "#{@resurrect-save-script-path} quiet"'
        '';
      }
    ];

    extraConfig = ''
      set -g set-clipboard on
      set -g status-position top
    '';
  };
}
