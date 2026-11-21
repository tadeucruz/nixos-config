{
  config,
  inputs,
  lib,
  options,
  pkgs,
  ...
}:
let
  inherit (lib) optionalAttrs;

  # HM master exposes the V2 terminal-client options; release-26.05 (omega) does not.
  hmHasV2 = options.programs.opencode ? cli;

  # Same opencode version on every host, including those tracking nixpkgs-stable.
  opencode = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.opencode;

  mkLocal =
    {
      name,
      baseURL,
      models,
    }:
    {
      inherit name;
      package = "@opencode/ai/providers/openai-compatible";
      settings = {
        inherit baseURL;
        apiKey = "EMPTY";
      };
      inherit models;
    };

  localModel =
    {
      name,
      context,
      output,
    }:
    {
      inherit name;
      capabilities = {
        tools = true;
        reasoning.supported = true;
      };
      compatibility.reasoningField = "reasoning_content";
      limit = { inherit context output; };
    };
in
{
  programs.opencode = {
    enable = true;
    package = opencode;
    # Global instructions, loaded in every session (shared with pi).
    context = ../ai/AGENTS.md;

    # Model IDs must match llama-server's `--alias` (see llama-server.md), otherwise
    # opencode asks for a model the server does not advertise.
    settings = {
      model = "openrouter/openrouter/auto";
      update = "disable"; # the binary is managed by Nix
      providers = {
        ornith = mkLocal {
          name = "Normandy";
          baseURL = "http://localhost:9931/v1";
          models = {
            "ornith-ai/Ornith-1.5-9B-GGUF:Q4_K_M" = localModel {
              name = "Ornith-1.5-9B Q4_K_M";
              context = 65536;
              output = 32768;
            };
            "ornith-ai/Ornith-1.5-9B-GGUF:Q8_0" = localModel {
              name = "Ornith-1.5-9B Q8_0";
              context = 32768;
              output = 16384;
            };
          };
        };
        ornith-citadel = mkLocal {
          name = "Citadel";
          baseURL = "http://citadel:9931/v1";
          models."ornith-ai/Ornith-1.5-9B-GGUF:Q8_0" = localModel {
            name = "Ornith-1.5-9B Q8_0";
            context = 131072;
            output = 32768;
          };
        };
        ornith-prothean = mkLocal {
          name = "Prothean";
          baseURL = "http://prothean:9931/v1";
          models."ornith-ai/Ornith-1.5-9B-GGUF:Q4_K_M" = localModel {
            name = "Ornith-1.5-9B Q4_K_M";
            context = 65536;
            output = 32768;
          };
        };
      };
    };
  }
  // optionalAttrs hmHasV2 {
    mutableSettings = true; # the TUI rewrites cli.json
    validateFiles = {
      config = true;
      cli = true;
    };
  };

  # OpenRouter key comes from agenix; writing it at activation keeps it out of the
  # store. jq merges so providers connected through /connect survive.
  home.activation.opencodeAuth = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    secret=/run/agenix/openrouter-token
    auth="${config.xdg.dataHome}/opencode/auth.json"
    if [[ -r "$secret" ]]; then
      run mkdir -p "${config.xdg.dataHome}/opencode"
      tmp="$auth.tmp.$$"
      ${pkgs.jq}/bin/jq --arg k "$(< "$secret")" \
        '.openrouter = { type: "api", key: $k }' "$auth" > "$tmp" 2>/dev/null \
        || ${pkgs.jq}/bin/jq -n --arg k "$(< "$secret")" \
             '.openrouter = { type: "api", key: $k }' > "$tmp"
      run chmod 600 "$tmp"
      run mv -f "$tmp" "$auth"
    fi
  '';
}
