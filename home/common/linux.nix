# Linux-only Home Manager config (citadel + prothean + legion).
{ pkgs, lib, username, ... }:
{
  home = {
    homeDirectory = "/home/${username}";
    sessionVariables = {
      SSH_AUTH_SOCK = "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock";
    };
  };

  # kbuildsycoca's incremental check misses store path hash changes on every rebuild, causing stale KDE plasmoid popups.
  home.activation.rebuildKdeSycoca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.getExe' pkgs.kdePackages.kservice "kbuildsycoca6"} --noincremental || true
  '';

  programs.zsh.shellAliases.rebuild = "cd $NH_FLAKE && git pull && nh os switch";
}
