# AI agent tooling (AI CLIs, usable locally or over ssh) — not dev tooling.
{
  imports = [
    ./programs/claude-code.nix
    ./programs/cline.nix
    ./programs/opencode.nix
  ];
}
