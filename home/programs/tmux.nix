{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    # Core: standard prefix, emacs keys, mouse, sensible splits, generous scrollback.
    prefix = "C-b";
    keyMode = "emacs";
    mouse = true;
    baseIndex = 1;
    # Small nonzero delay: 0 makes tmux skip reassembling ESC-prefixed key
    # sequences, breaking Delete/setas/End (and thus editing after fzf).
    # 10ms is enough and below noticeable for ESC in vim.
    escapeTime = 10;
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
        #  - @resurrect-dir: pin the save location explicitly instead of relying
        #    on the pinned plugin's default (this tmux-resurrect version already
        #    defaults to ~/.tmux/resurrect — set here so a future plugin bump
        #    never silently moves the history)
        #  - @resurrect-processes ':all:': re-run every program that was running
        #    (default only restores a built-in whitelist: vim/nvim, less, ssh, ...)
        #  - @resurrect-capture-pane-contents: also restore each pane's scrollback
        extraConfig = ''
          set -g @resurrect-dir '~/.tmux/resurrect'
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

      # Forward the active pane's title (set by the shell via OSC 0, see
      # programs.zsh.initContent) to the outer terminal, so GNOME Console tab
      # labels follow the pane's cwd instead of freezing at whatever the title
      # was when tmux started.
      set -g set-titles on
      set -g set-titles-string '#T'
    '';
  };
}
