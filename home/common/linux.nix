{
  pkgs,
  lib,
  username,
  ...
}:
{
  home = {
    homeDirectory = "/home/${username}";
    sessionVariables = {
      SSH_AUTH_SOCK = "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock";
    };
  };

  home.activation.rebuildKdeSycoca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.getExe' pkgs.kdePackages.kservice "kbuildsycoca6"} --noincremental || true
  '';
  
  programs.zsh.shellAliases.rebuild = "cd $NH_FLAKE && git pull && systemd-inhibit --what=sleep --why='Nix build' nh os switch && nh clean all --keep-since 4d --keep 3";
}
