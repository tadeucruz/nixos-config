{ pkgs, ... }:
let
  # nixpkgs nixos-unstable pins aider 0.86.1 without the litellm
  # VectorStoreSearchError exception (added in nixpkgs master only), so the
  # strict audit in LiteLLMExceptions._load() fails the build and would break
  # at runtime. Mirror the master fix; remove once nixpkgs bumps aider past
  # 0.86.1.
  aider = pkgs.aider-chat.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./aider-vector-store-search-error.patch ];
  });
in
{
  home.packages = [ aider ];

  home.file.".aider.conf.yml".text = ''
    model: ollama/llama3
    dark-mode: true
    cache-prompts: true
    auto-commits: true
  '';
}
