{
  pkgs,
  hostname,
  ...
}:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = false;
    syntaxHighlighting.enable = true;

    # Terminal/tab title: terminals without a title setting (e.g. macOS
    # Terminal.app) rely on the OSC 0 title emitted from inside the terminal,
    # so without this the label stays the generic default. Re-emitted on every
    # prompt so `cd` (and exiting vim/htop, which clear the title) is reflected;
    # preexec shows the running command meanwhile. Also works over SSH.
    # add-zsh-hook instead of a bare `precmd()` so starship's hook isn't
    # clobbered.
    initContent = ''
      autoload -Uz add-zsh-hook

      set-dir-title() {
        print -Pn '\e]0;%n@%m: %~\a'
      }

      set-cmd-title() {
        # $1 is the command line as typed; printf %s keeps it literal so
        # `%` chars in the command can't be interpreted.
        printf '\e]0;%s | %s\a' "$(print -P '%n@%m: %~')" "$1"
      }

      add-zsh-hook precmd set-dir-title
      add-zsh-hook preexec set-cmd-title
    '';

    shellAliases = {
      ls = if pkgs.stdenv.hostPlatform.isDarwin then "ls -G" else "ls --color=auto";
      ll = "ls -alh";
      # Reattach to the most recent tmux session, or create one if there's none.
      # Bare `tmux` always spawns a NEW session — it never reattaches on its own.
      ta = "tmux attach 2>/dev/null || tmux new-session";
      rebuild =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "cd $NH_DARWIN_FLAKE && git pull && nh darwin switch -H ${hostname} && nh clean all --keep-since 4d --keep 3"
        else
          "cd $NH_FLAKE && git pull && systemd-inhibit --what=sleep --why='Nix build' nh os switch && nh clean all --keep-since 4d --keep 3";
    };
  };
}
