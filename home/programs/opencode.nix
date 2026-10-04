{ pkgs, ... }:
{
  home.packages = [ pkgs.opencode ];

  xdg.configFile."opencode/opencode.jsonc".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "provider": {
        "ollama": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "Ollama",
          "options": {
            "baseURL": "http://citadel.tail0a0fce.ts.net:11434/v1"
          },
          "models": {
            "qwen3.5": {
              "name": "qwen3.5"
            }
          }
        }
      }
    }
  '';
}
