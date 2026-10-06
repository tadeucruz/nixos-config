{
  pkgs,
  hostname,
  ...
}:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = "set -g fish_greeting ''";
    shellAliases = {
      ls = if pkgs.stdenv.hostPlatform.isDarwin then "ls -G" else "ls --color=auto";
      ll = "ls -alh";
      ta = "tmux attach 2>/dev/null || tmux new-session";
      rebuild =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "cd $NH_DARWIN_FLAKE && git pull && nh darwin switch -H ${hostname} && nh clean all --keep-since 4d --keep 3"
        else
          "cd $NH_FLAKE && git pull && systemd-inhibit --what=sleep --why='Nix build' nh os switch && nh clean all --keep-since 4d --keep 3";
    };
  };
}
