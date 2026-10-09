{ pkgs, ... }:
{
  home.packages = [ pkgs.opencode ];

  xdg.configFile."opencode/opencode.jsonc".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "provider": {
        "llama-cpp": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "llama.cpp",
          "options": {
            "baseURL": "http://citadel.tail0a0fce.ts.net:8080/v1"
          },
          "models": {
            "qwen3.8": {
              "name": "qwen3.8 (citadel)"
            }
          }
        }
      }
    }
  '';
}
