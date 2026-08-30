{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    host = "0.0.0.0";
    openFirewall = true;
    loadModels = [ "deepseek-r1:14b" ];
    syncModels = true;
  };

  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 3000;
    openFirewall = true;
  };
}
