{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    # Behaviour close to herdr: same prefix, mouse-first, vi pane navigation.
    prefix = "C-b";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 100000;
    newSession = true;
    sensibleOnTop = true;

    # Session/layout restore (herdr's "detach without stopping work").
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
      vim-tmux-navigator
      catppuccin
    ];

    extraConfig = ''
      # Side-by-side panes: | split right, - split down (v/s as mnemonics).
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"

      # Jump between panes with Alt+arrows, no prefix needed.
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Copy to the system clipboard (works over ssh via OSC 52).
      set -g set-clipboard on

      # Flavour for the catppuccin plugin loaded from `plugins`.
      set -g @catppuccin_flavour 'mocha'
    '';
  };
}
