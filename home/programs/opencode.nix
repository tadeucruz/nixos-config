{ pkgs, ... }:
{
  home.packages = [ pkgs.opencode ];

  xdg.configFile."opencode/opencode.jsonc".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "small_model": "openrouter/deepseek/deepseek-v4-flash:free",
      "compaction": {
        "auto": true,
        "prune": true,
        "tail_turns": 10,
        "preserve_recent_tokens": 20000
      },
      "tool_output": {
        "max_lines": 500,
        "max_bytes": 20000
      }
    }
  '';
}
