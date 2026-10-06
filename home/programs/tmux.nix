{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    # Core: standard prefix, emacs keys, mouse, sensible splits, generous scrollback.
    prefix = "C-b";
    keyMode = "emacs";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 100000;
    newSession = true;
    sensibleOnTop = true;

    # Plugins.
    #  - dracula: theme (owns status-left/status-right)
    #  - resurrect + continuum: manual and automatic session state save/restore
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-show-powerline true
          set -g @dracula-show-left-icon session
          set -g @dracula-plugins "time git cwd"
        '';
      }
      {
        plugin = resurrect;
        # Restore state is read by resurrect at restore time, so these live in the
        # plugin's own extraConfig (see AGENTS.md note on plugin load order).
        #  - @resurrect-processes ':all:': re-run every program that was running
        #    (default only restores a built-in whitelist: vim/nvim, less, ssh, ...)
        #  - @resurrect-capture-pane-contents: also restore each pane's scrollback
        extraConfig = ''
          set -g @resurrect-processes ':all:'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
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
