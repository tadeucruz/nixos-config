{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Lista de secrets e seus mapeamentos para env vars
  # Formato: { secret_name = "ENV_VAR_NAME"; }
  secretMappings = {
    openroute_token = "OPENROUTESERVICE_API_KEY";
    # Exemplos de outros mapeamentos:
    # github_token = "GITHUB_TOKEN";
    # api_key = "API_KEY";
  };

  # Gerar script bash que carrega todos os secrets
  envScriptContent = lib.concatStrings (
    lib.mapAttrsToList (secret: envVar: ''
      # ${envVar}
      if [[ -f "/run/secrets/${secret}" ]]; then
        export ${envVar}="$(cat "/run/secrets/${secret}")"
      fi
    '') secretMappings
  );

  # Script para recarregar que pode ser chamado via eval
  reloadScript = pkgs.writeShellScriptBin "reload-sops-secrets" ''
    # Recarrega todas as environment variables de secrets
    ${envScriptContent}
    echo "SOPS secrets recarregados"
  '';
in
{
  config = {
    home.packages = [ reloadScript ];

    # Arquivo que é sourceado no shell
    home.file.".config/sops/env.sh" = {
      text = ''
        # Environment variables de secrets (gerado automaticamente)
        # Para recarregar: source ~/.config/sops/env.sh
        # Ou usar: reload-sops-secrets
        ${envScriptContent}
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
        if command -v reload-sops-secrets >/dev/null 2>&1; then
          eval "$(reload-sops-secrets)"
          echo "SOPS secrets recarregados"
        else
          if [[ -f "$HOME/.config/sops/env.sh" ]]; then
            source "$HOME/.config/sops/env.sh"
            echo "Secrets recarregados"
          fi
        fi
      }
    '';
  };
}
