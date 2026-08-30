{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    host = "0.0.0.0";
    openFirewall = true;
    environmentVariables = {
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
    };
    loadModels = [ "deepseek-r1:7b" ];
    syncModels = true;
  };

  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 3000;
    openFirewall = true;
  };
}
