{ ... }:
{
  imports = [
    ../common/base.nix
    ../common/packages.nix
    ../common/linux.nix
    ../programs/firefox.nix
    ../programs/ungoogled-chromium.nix
    ../programs/git.nix
    ../programs/starship.nix
    ../programs/fzf.nix
    ../programs/zsh.nix
    ../programs/tmux.nix
    ../programs/home-manager.nix
    ../programs/llama-cpp.nix
    ../development.nix
    ../ai.nix
    ../programs/neovim.nix
    ../programs/flutter.nix
    ../gaming.nix
  ];

  llama-cpp.gpu = "cuda";

  home.stateVersion = "26.11";

  home.sessionVariables = {
    PROTON_ENABLE_WAYLAND = "1";
    SteamDeck = "0";
  };
}
