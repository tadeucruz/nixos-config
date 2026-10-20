{ pkgs, ... }:
{
  home.packages = [ pkgs.opencode ];

  xdg.configFile."opencode/opencode.jsonc".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "provider": {
        "ornith": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "Ornith (local)",
          "options": {
            "baseURL": "http://localhost:9931/v1",
            "apiKey": "EMPTY"
          },
          "models": {
            "ornith-1.5-9b": {
              "name": "Ornith-1.5-9B"
            }
          }
        },
        "ornith-citadel": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "Ornith (citadel)",
          "options": {
            "baseURL": "http://citadel:9931/v1",
            "apiKey": "EMPTY"
          },
          "models": {
            "ornith-1.5-9b": {
              "name": "Ornith-1.5-9B (citadel)"
            }
          }
        },
        "ornith-prothean": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "Ornith (prothean)",
          "options": {
            "baseURL": "http://prothean:9931/v1",
            "apiKey": "EMPTY"
          },
          "models": {
            "ornith-1.5-9b": {
              "name": "Ornith-1.5-9B (prothean)"
            }
          }
        }
      }
    }
  '';
}
