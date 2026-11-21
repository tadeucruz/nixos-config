{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Caminho absoluto para o diretório de secrets (relativo à raiz do repo)
  secretsDir = ../../secrets;
in
{
  imports = [
    # Nenhum import necessário aqui, apenas configurações
  ];

  config = {
    # Configuração do sops-nix
    sops = {
      defaultSopsFile = secretsDir + "/secrets.yaml";
      # Para age key única em todas as máquinas
      # A chave privada deve estar disponível em cada máquina no seguinte caminho:
      # /home/tadeucruz/.config/sops/age/keys.txt
      age.keyFile = "/home/tadeucruz/.config/sops/age/keys.txt";
      # Não usar SSH keys pois as chaves privadas estão no Bitwarden
      age.sshKeyPaths = [ ];

      # Secrets - definiremos aqui os secrets específicos
      secrets = {
        # Token do OpenRouteService para pi-agent e opencode
        openroute_token = {
          sopsFile = secretsDir + "/secrets.yaml";
          # Path onde o secret será disponibilizado
          path = "/run/secrets/openroute_token";
          mode = "0400";
          owner = config.users.users.tadeucruz.name;
          restartUnits = [ ];
        };
      };
    };

    # Para outras máquinas além do prothean:
    # 1. Copie o módulo sops para cada host
    # 2. Adicione o módulo "home/programs/sops.nix" ao home-manager de cada host
    # 3. Coloque a chave privada age em ~/.config/sops/age/keys.txt em cada máquina
  };
}
