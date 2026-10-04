# Ollama — LLM runner (on-demand: `ollama serve`; no auto-start service).
# GPU backend per host via `ollama.gpu`: rocm (AMD/citadel), cuda (Nvidia/prothean),
# metal (default — darwin uses Metal automatically, Linux falls back to CPU).
# Listens on 0.0.0.0 so tailnet peers reach it; the firewall already trusts
# tailscale0 (modules/services/tailscale.nix), so LAN/external stay blocked.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.ollama.gpu = lib.mkOption {
    type = lib.types.enum [
      "metal"
      "rocm"
      "cuda"
    ];
    default = "metal";
    description = "Ollama GPU backend: metal (darwin/CPU), rocm (AMD), cuda (Nvidia).";
  };

  config = {
    home.packages = [
      (
        {
          metal = pkgs.ollama;
          rocm = pkgs.ollama-rocm;
          cuda = pkgs.ollama-cuda;
        }
        .${config.ollama.gpu}
      )
    ];

    home.sessionVariables.OLLAMA_HOST = lib.mkDefault "0.0.0.0:11434";
  };
}
