{
  config,
  pkgs,
  lib,
  ...
}:
let
  # List of secrets and their mappings to env vars
  # Format: { secret_name = "ENV_VAR_NAME"; }
  secretMappings = {
    openroute_token = "OPENROUTESERVICE_API_KEY";
    # Examples of other mappings:
    # github_token = "GITHUB_TOKEN";
    # api_key = "API_KEY";
  };

  # Generate bash script that loads all secrets
  envScriptContent = lib.concatStrings (
    lib.mapAttrsToList (secret: envVar: ''
      # ${envVar}
      if [[ -f "/run/secrets/${secret}" ]]; then
        export ${envVar}="$(cat "/run/secrets/${secret}")"
      fi
    '') secretMappings
  );

  # Script to reload that can be called via eval
  reloadScript = pkgs.writeShellScriptBin "reload-sops-secrets" ''
    # Reload all secrets environment variables
    ${envScriptContent}
    echo "SOPS secrets reloaded"
  '';
in
{
  config = {
    home.packages = [ reloadScript ];

    # File that gets sourced in the shell
    home.file.".config/sops/env.sh" = {
      text = ''
        # Secrets environment variables (automatically generated)
        # To reload: source ~/.config/sops/env.sh
        # Or use: reload-sops-secrets
        ${envScriptContent}
      '';
      executable = false;
    };

    # Source the file in zsh
    programs.zsh.initContent = lib.mkAfter ''
      # Load secrets environment variables
      if [[ -f "$HOME/.config/sops/env.sh" ]]; then
        source "$HOME/.config/sops/env.sh"
      fi

      # Helper function to reload secrets
      reload-secrets() {
        if command -v reload-sops-secrets >/dev/null 2>&1; then
          eval "$(reload-sops-secrets)"
          echo "SOPS secrets reloaded"
        else
          if [[ -f "$HOME/.config/sops/env.sh" ]]; then
            source "$HOME/.config/sops/env.sh"
            echo "Secrets reloaded"
          fi
        fi
      }
    '';
  };
}
