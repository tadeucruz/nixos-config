{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = {
    # Environment variables injetadas via systemd environment
    # O sops-nix disponibiliza os secrets em /run/secrets/
    # Podemos configurar um service ou usar um hook de login

    # Alternativa: criar um arquivo que é sourceado no shell
    home.file.".config/sops/env.sh" = {
      text = ''
        # Environment variables de secrets
        # Este arquivo é gerado automaticamente
        # Para recarregar: source ~/.config/sops/env.sh

        # OpenRouteService token
        if [[ -f "/run/secrets/openroute_token" ]]; then
          export OPENROUTESERVICE_API_KEY="$(cat /run/secrets/openroute_token)"
        fi
      '';
      executable = false;
    };

    # Source o arquivo no zsh
    programs.zsh.initContent = lib.mkAfter ''
      # Carregar environment variables de secrets
      if [[ -f "$HOME/.config/sops/env.sh" ]]; then
        source "$HOME/.config/sops/env.sh"
      fi

      # Função helper para recarregar secrets
      reload-secrets() {
        if [[ -f "$HOME/.config/sops/env.sh" ]]; then
          source "$HOME/.config/sops/env.sh"
          echo "Secrets recarregados"
        fi
      }
    '';
  };
}
