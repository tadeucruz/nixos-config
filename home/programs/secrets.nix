{ lib, ... }:
{
  # Decrypted by agenix at activation/boot (system-level module).
  programs.zsh.initContent = lib.mkAfter ''
    if [[ -r /run/agenix/openroute-token ]]; then
      export OPENROUTESERVICE_API_KEY="$(< /run/agenix/openroute-token)"
    fi
  '';
}
