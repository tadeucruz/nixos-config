# Hermes Agent (omega): gateway runs inside a Podman-backed Ubuntu container.
{ ... }:
{
  services.hermes-agent = {
    enable = true;
    container = {
      enable = true;
      backend = "podman"; # omega runs containers via Podman (dockerCompat socket)
      hostUsers = [ "tadeucruz" ]; # group access to HERMES_HOME + ~/.hermes bridge
    };

    # llama.cpp on prothean (same id used by opencode.nix).
    settings.model = {
      default = "ornith-ai/Ornith-1.5-9B-GGUF:Q4_K_M";
      provider = "custom";
      base_url = "http://prothean.tail0a0fce.ts.net:9931/v1";
    };

    # Not secrets: written to $HERMES_HOME/.env (0640). OPENAI_BASE_URL must
    # match model.base_url so the module hands OPENAI_API_KEY to the endpoint.
    environment = {
      OPENAI_BASE_URL = "http://prothean.tail0a0fce.ts.net:9931/v1";
      OPENAI_API_KEY = "EMPTY";
    };

    addToSystemPackages = true; # hermes on PATH + shared HERMES_HOME
  };
}
