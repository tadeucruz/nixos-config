{ pkgs, ... }:
{
  home.packages = [ pkgs.pi-coding-agent ];

  # Static pi resources only. settings.json, auth.json and sessions/ stay native:
  # pi writes to them (`pi install`, /settings, /login), so a store symlink breaks it.
  home.file = {
    ".pi/agent/models.json".source = ./pi/models.json;
    ".pi/agent/AGENTS.md".source = ./pi/AGENTS.md;
  };
}
