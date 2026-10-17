{
  lib,
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # Write the yank to the system clipboard when one is reachable: wl-copy on a
  # local Wayland session, pbcopy on macOS. Over SSH there is no local
  # clipboard, so drain stdin instead — tmux still sends OSC 52 to the client.
  copyToClipboard = pkgs.writeShellScript "tmux-copy-clipboard" (
    if isDarwin then
      ''
        /usr/bin/pbcopy
      ''
    else
      ''
        if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
          ${pkgs.wl-clipboard}/bin/wl-copy
        else
          cat >/dev/null
        fi
      ''
  );

  # Modern tmux routes every copy-pipe binding (mouse yank, M-w/C-w, Enter on
  # vi) through this command, so it is also where the "Copied" banner lives.
  copyCommand = pkgs.writeShellScript "tmux-copy" ''
    ${copyToClipboard}
    ${pkgs.tmux}/bin/tmux display-message -d 1000 Copied
  '';
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
      # OSC 52 (set-clipboard) only reaches terminals that implement it — macOS
      # Terminal.app and konsole do not. copy-command pipes every yank/mouse
      # selection to the real system clipboard instead (when one is reachable),
      # and ends by printing the "Copied" banner. Over SSH the script no-ops
      # the clipboard part and tmux still sends OSC 52 to the client.
      set -g set-clipboard on
      set -g copy-command '${copyCommand}'

      # tmux 3.7 no longer binds Enter in emacs copy-mode; wire it to the same
      # copy-pipe path as the mouse yank so it copies and shows the banner.
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
