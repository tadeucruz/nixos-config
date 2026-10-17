{ pkgs, ... }:
{
  home.packages = [ pkgs.opencode ];

  xdg.configFile."opencode/opencode.jsonc".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "provider": {
        "personal-llama-cpp": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "personal-llama-cpp",
          "options": {
            "baseURL": "http://prothean:9931/v1"
          },
          "models": {
            "unsloth/Qwen2.5-Coder-7B-Instruct-GGUF:Q4_K_M": {
              "name": "local prothean"
            }
          }
        }
      }
    }
  '';
}
