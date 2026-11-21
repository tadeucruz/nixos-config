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
    ../programs/llama-cpp.nix
    ../programs/return-to-steam.nix
    ../ai.nix
    ../gaming.nix
  ];

  llama-cpp.gpu = "rocm";

  home.stateVersion = "26.11";
}
