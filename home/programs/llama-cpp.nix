# llama.cpp — LLM runner (on-demand: `llama-server`; no auto-start service).
# GPU backend per host via `llama-cpp.gpu`: rocm (AMD/citadel), cuda (Nvidia/prothean),
# metal (default — darwin uses Metal automatically, Linux falls back to CPU).
# LLAMA_ARG_HOST/PORT make the server listen on 0.0.0.0:9931 so tailnet peers
# reach it; the firewall already trusts tailscale0 (modules/services/tailscale.nix),
# so LAN/external stay blocked.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.llama-cpp.gpu = lib.mkOption {
    type = lib.types.enum [
      "metal"
      "rocm"
      "cuda"
    ];
    default = "metal";
    description = "llama.cpp GPU backend: metal (darwin/CPU), rocm (AMD), cuda (Nvidia).";
  };

  config = {
    home.packages = [
      (
        {
          metal = pkgs.llama-cpp;
          rocm = pkgs.llama-cpp-rocm;
          cuda = pkgs.llama-cpp.override { cudaSupport = true; };
        }
        .${config.llama-cpp.gpu}
      )
    ];

    home.sessionVariables = {
      LLAMA_ARG_HOST = lib.mkDefault "0.0.0.0";
      LLAMA_ARG_PORT = lib.mkDefault "9931";
    };
  };
}
