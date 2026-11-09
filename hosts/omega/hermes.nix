# Hermes Agent (omega): runs inside a Podman-backed Ubuntu container so it is
# not running loose on the host. Secrets live in /etc/hermes/env (mode 0600).
{ ... }:
let
  envFile = ''
    OPENAI_BASE_URL="http://prothean:9931/v1"
    OPENAI_API_KEY="EMPTY"
    MODEL="ornith-ai/Ornith-1.5-9B-GGUF:Q4_K_M"
  '';
in
{
  services.hermes-agent = {
    enable = true;
    container = {
      enable = true;
      backend = "podman"; # omega runs containers via Podman (dockerCompat socket)
    };
    settings.model.default = "anthropic/claude-sonnet-4"; # placeholder: set your provider/model + keys in /etc/hermes/env
    environmentFiles = [ "/etc/hermes/env" ];
  };

  virtualisation.docker.enable = false; # hermes auto-enables Docker by default; omega uses Podman instead

  systemd.tmpfiles.rules = [
    "d /etc/hermes 750 root root -"
    "f /etc/hermes/env 600 root root ${envFile}"
  ];
}
