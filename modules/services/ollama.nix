{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cpu;
    loadModels = [ "deepseek-r1:14b" ];
  };

  services.open-webui = {
    enable = true;
    openFirewall = true;
  };
}
