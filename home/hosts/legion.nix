{ ... }:
{
  imports = [
    ../common/base.nix
    ../common/packages.nix
    ../common/linux.nix
    ../programs/firefox.nix
    ../programs/git.nix
    ../programs/starship.nix
    ../programs/fzf.nix
    ../programs/zsh.nix
    ../programs/tmux.nix
    ../programs/home-manager.nix
    ../ai.nix
    ../gaming.nix
  ];

  home.stateVersion = "26.11";

  xdg.desktopEntries.return-to-steam = {
    name = "Return to Steam";
    comment = "Switch back to Steam Big Picture session";
    exec = "start-gamescope-session";
    icon = "steam";
    terminal = false;
    categories = [ "Game" ];
  };
}
