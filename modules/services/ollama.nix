# Ollama — local LLM runtime, exposed to open-webui (on omega) and any
# LAN/Tailscale client. Bound to all interfaces on :11434 with the firewall
# opened, so the server side can reach it over the network.
#
# Acceleration: on nixos-26.05 the old `services.ollama.acceleration` option is
# gone — the runtime is selected through the package instead. Plain `pkgs.ollama`
# follows `nixpkgs.config`: with `rocmSupport` enabled (as citadel does via
# modules/desktop/rocm.nix) it resolves to `ollama-rocm` (RDNA GPU); with
# `cudaSupport` to `ollama-cuda`; otherwise to `ollama-cpu`. If ROCm fails to
# detect the GPU, pin it with `services.ollama.rocmOverrideGfx` (e.g. "12.0.0"
# on RDNA4), or fall back to `pkgs.ollama-vulkan`.
#
# Models are pulled imperatively (`ollama pull <model>`) into /var/lib/ollama.
{ ... }:
{
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
  };
}
