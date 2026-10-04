# Ollama — LLM runner (on-demand: `ollama serve`; no auto-start service).
# Linux (prothean): CUDA build for the Nvidia dGPU; darwin (normandy): stock
# build (uses Metal automatically on Apple Silicon; ollama-cuda is Linux-only).
{ pkgs, ... }:
{
  home.packages = [
    (if pkgs.stdenv.hostPlatform.isLinux then pkgs.ollama-cuda else pkgs.ollama)
  ];
}
