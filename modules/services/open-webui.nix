# Open-WebUI (omega) — frontend for LLM chat, backed by OpenRouter instead of
# a local Ollama. The API key lives outside git in /etc/openrouter/key
# (OPENAI_API_KEY=sk-or-...), loaded via environmentFile; OPENAI_API_BASE_URL
# points everything at the OpenRouter endpoint.
{ ... }:
{
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 3000;
    openFirewall = true;
  };
}
