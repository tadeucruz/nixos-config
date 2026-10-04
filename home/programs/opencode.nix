{ pkgs, ... }:
{
  home.packages = [ pkgs.opencode ];

  xdg.configFile."opencode/opencode.jsonc".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "model": "ollama/gemma4:26b",
      "provider": {
        "ollama": {
          "npm": "@ai-sdk/ollama",
          "options": {
            "baseURL": "http://citadel.tail0a0fce.ts.net:11434/api"
          },
          "models": {
            "gemma4:26b": { "name": "Gemma 4 26B (citadel)" }
          }
        }
      },
      "compaction": {
        "auto": true,
        "prune": true,
      }
    }
  '';
}
