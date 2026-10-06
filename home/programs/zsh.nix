{
  pkgs,
  hostname,
  ...
}:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = if pkgs.stdenv.hostPlatform.isDarwin then "ls -G" else "ls --color=auto";
      ll = "ls -alh";
      # Reattach to the most recent tmux session. Bare `tmux` always spawns a
      # NEW session — it never reattaches on its own.
      ta = "tmux attach";
      rebuild =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "cd $NH_DARWIN_FLAKE && git pull && nh darwin switch -H ${hostname} && nh clean all --keep-since 4d --keep 3"
        else
          "cd $NH_FLAKE && git pull && systemd-inhibit --what=sleep --why='Nix build' nh os switch && nh clean all --keep-since 4d --keep 3";
    };
  };
}
