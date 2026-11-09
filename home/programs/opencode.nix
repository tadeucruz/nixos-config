{ pkgs, ... }:
{
  home.packages = [ pkgs.opencode ];

  # Model IDs must match llama-server's `--alias` (see llama-server.md), otherwise
  # opencode asks for a model the server does not advertise.
  xdg.configFile."opencode/opencode.jsonc".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "provider": {
        "ornith": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "Normandy",
          "options": {
            "baseURL": "http://localhost:9931/v1",
            "apiKey": "EMPTY"
          },
          "models": {
            "ornith-ai/Ornith-1.5-9B-GGUF:Q4_K_M": {
              "name": "Ornith-1.5-9B Q4_K_M",
              "reasoning": true,
              "tool_call": true,
              "temperature": true,
              "interleaved": "reasoning_content",
              "limit": {
                "context": 65536,
                "output": 32768
              }
            },
            "ornith-ai/Ornith-1.5-9B-GGUF:Q8_0": {
              "name": "Ornith-1.5-9B Q8_0",
              "reasoning": true,
              "tool_call": true,
              "temperature": true,
              "interleaved": "reasoning_content",
              "limit": {
                "context": 32768,
                "output": 16384
              }
            }
          }
        },
        "ornith-citadel": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "Citadel",
          "options": {
            "baseURL": "http://citadel:9931/v1",
            "apiKey": "EMPTY"
          },
          "models": {
            "ornith-ai/Ornith-1.5-9B-GGUF:Q8_0": {
              "name": "Ornith-1.5-9B Q8_0",
              "reasoning": true,
              "tool_call": true,
              "temperature": true,
              "interleaved": "reasoning_content",
              "limit": {
                "context": 131072,
                "output": 32768
              }
            }
          }
        },
        "ornith-prothean": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "Prothean",
          "options": {
            "baseURL": "http://prothean:9931/v1",
            "apiKey": "EMPTY"
          },
          "models": {
            "ornith-ai/Ornith-1.5-9B-GGUF:Q4_K_M": {
              "name": "Ornith-1.5-9B Q4_K_M",
              "reasoning": true,
              "tool_call": true,
              "temperature": true,
              "interleaved": "reasoning_content",
              "limit": {
                "context": 65536,
                "output": 32768
              }
            }
          }
        }
      }
    }
  '';
}
