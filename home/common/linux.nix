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
}
