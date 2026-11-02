{ ... }:
{
  imports = [
    ../common/base.nix
    ../common/packages.nix
    ../common/linux.nix
    ../programs/firefox.nix
    ../programs/ungoogled-chromium.nix
    ../programs/bitwarden.nix
    ../programs/git.nix
    ../programs/starship.nix
    ../programs/fzf.nix
    ../programs/zsh.nix
    ../programs/tmux.nix
    ../programs/home-manager.nix
    ../programs/return-to-steam.nix
    ../ai.nix
    ../gaming.nix
  ];

  # Steam Input controller-as-mouse on the KDE desktop: the prompt never
  # persists (XWayland has no app-id), so re-assert the permission each login.
  programs.kdePortalPermissions.remoteDesktop = true;

  home.stateVersion = "26.11";
}
