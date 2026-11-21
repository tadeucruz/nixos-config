{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Absolute path to secrets directory (relative to repo root)
  secretsDir = ../../secrets;
in
{
  imports = [
    # No imports needed here, just configurations
  ];

  config = {
    # sops-nix configuration
    sops = {
      defaultSopsFile = secretsDir + "/secrets.yaml";
      # For single age key across all machines
      # Private key must be available on each machine at:
      # /home/tadeucruz/.config/sops/age/age-secret-key.txt
      age.keyFile = "/home/tadeucruz/.config/sops/age/age-secret-key.txt";
      # Don't use SSH keys since private keys are in Bitwarden
      age.sshKeyPaths = [ ];

      # Secrets - define specific secrets here
      secrets = {
        # OpenRouteService token for pi-agent and opencode
        openroute_token = {
          sopsFile = secretsDir + "/secrets.yaml";
          # Path where secret will be available
          path = "/run/secrets/openroute_token";
          mode = "0400";
          owner = config.users.users.tadeucruz.name;
          restartUnits = [ ];
        };
      };
    };

    # For other machines besides prothean:
    # 1. Copy sops module to each host
    # 2. Add "home/programs/sops.nix" module to each host's home-manager
    # 3. Place age private key in ~/.config/sops/age/age-secret-key.txt on each machine
  };
}
