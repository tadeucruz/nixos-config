# stable-diffusion.cpp — diffusion model runner (on-demand: `sd`; no auto-start service).
# The nixpkgs build enables Metal by default on darwin/aarch64 (normandy's Apple
# Silicon), so no override is needed here. Model files (checkpoints/VAE/LoRA) are
# fetched by the user, not declared in the repo.
{ pkgs, ... }:
{
  home.packages = [ pkgs.stable-diffusion-cpp ];
}
