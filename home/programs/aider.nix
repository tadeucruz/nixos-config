{ pkgs, ... }:
{
  home.packages = [ pkgs.aider-chat ];

  home.file.".aider.conf.yml".text = ''
    dark-mode: true
    cache-prompts: true
  '';
}
