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
    #
    # Order/placement matters (verified against the generated tmux.conf):
    #  * Home Manager emits each plugin's own `extraConfig` right before its
    #    `run-shell`, and `run-shell` blocks. The top-level `extraConfig` is
    #    emitted *after* the whole plugin block, so plugin options set there are
    #    read too late (the plugin already ran with defaults). Hence the options
    #    live in the plugin submodules below.
    #  * Dracula must load BEFORE continuum: dracula resets `status-right` on
    #    load, which would otherwise wipe the save-trigger interpolation that
    #    continuum injects into `status-right` (that drives the periodic save).
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-show-powerline true
          set -g @dracula-show-left-icon session
          # Dracula's default is "battery network weather"; the weather segment
          # (scripts/weather.sh) curls https://wttr.in and geo-locates us by IP
          # every 5s. Keep only local, no-network segments.
          set -g @dracula-plugins "time uptime git cwd"
        '';
      }
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          # Upstream default is 'off' — without this, continuum never restores.
          set -g @continuum-restore 'on'
          # Also save on detach (closing the terminal, ssh drop, ...), not just
          # every @continuum-save-interval (default 15 min), so a restore is
          # never more than one detach out of date.
          set-hook -g client-detached 'run-shell "#{@resurrect-save-script-path} quiet"'
        '';
      }
    ];

    extraConfig = ''
      # Copy to the system clipboard (works over ssh via OSC 52).
      set -g set-clipboard on

      # Put the status bar at the top of the window (not the bottom).
      set -g status-position top
    '';
  };
}
