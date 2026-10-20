{
  pkgs,
  ...
}:
let
  # Ghostty handles OSC 52 (local and over SSH). The copy command is only a
  # fallback for local terminals without OSC 52 (e.g. Konsole).
  copyCommand =
    if pkgs.stdenv.hostPlatform.isDarwin then "/usr/bin/pbcopy" else "${pkgs.wl-clipboard}/bin/wl-copy";
in
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
        #  - @resurrect-default-processes: neutralise the built-in whitelist
        #    (vi/vim/nvim/emacs/man/less/more/tail/top/htop/irssi/weechat/mutt)
        #    with a token that never matches a command — resurrect treats an
        #    empty string as "unset" and would fall back to the default list.
        #  - @resurrect-processes: re-open only these programs on restore
        #  - @resurrect-capture-pane-contents: also restore each pane's scrollback
        extraConfig = ''
          set -g @resurrect-dir '~/.tmux/resurrect'
          set -g @resurrect-default-processes '__none__'
          set -g @resurrect-processes 'btop opencode'
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
      # OSC 52 reaches Ghostty (local and over SSH). copy-command covers local
      # terminals that don't implement OSC 52 (e.g. Konsole) and is harmless
      # over SSH, where tmux also emits OSC 52.
      set -g set-clipboard on
      set -g copy-command '${copyCommand}'

      # tmux 3.7 no longer binds Enter in emacs copy-mode; wire it to the same
      # copy-pipe path as the mouse yank.
      bind -T copy-mode Enter send-keys -X copy-pipe-and-cancel
      bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel
      set -g status-position top

      # Forward the active pane's title (set by the shell via OSC 0, see
      # programs.zsh.initContent) to the outer terminal, so terminal tab
      # labels follow the pane's cwd instead of freezing at whatever the title
      # was when tmux started.
      set -g set-titles on
      set -g set-titles-string '#T'
    '';
  };
}
