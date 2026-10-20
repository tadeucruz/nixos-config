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
          # `rocmSupport`/`cudaSupport` default to `config.*`, which is global
          # (prothean enables rocmSupport for the iGPU), so pin both per host —
          # otherwise the CUDA build also gets the HIP backend and the AMD iGPU
          # shows up as a device.
          rocm = pkgs.llama-cpp.override {
            cudaSupport = false;
            rocmSupport = true;
          };
          cuda = pkgs.llama-cpp.override {
            cudaSupport = true;
            rocmSupport = false;
          };
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
