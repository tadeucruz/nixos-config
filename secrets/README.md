# Gerenciamento de Secrets com SOPS-nix

## Configuração Inicial

### 1. Gerar Chave Age (se ainda não fez)

```bash
nix shell nixpkgs#age --command age-keygen -o age-key.txt
```

**Salve a chave privada no Bitwarden!**

Chave pública gerada: `age1mhp7pdfscyw3v6qqc2twlhz36r64ryqf7sx5g004j84p8f6ps57qzc0lld`

### 2. Configurar Chave Privada nas Máquinas

Em cada máquina NixOS (citadel, prothean, legion, omega):

```bash
mkdir -p ~/.config/sops/age
# Cole o conteúdo de age-key.txt (chave privada) em:
vim ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

### 3. Editar Secrets

Para adicionar/editar secrets:

```bash
# Instalar sops temporariamente
nix shell nixpkgs#sops --command sops secrets/secrets.yaml
```

No editor que abrir, adicione/edite os valores:

```yaml
openroute_token: "seu_token_aqui"
# outros_secrets: "valores"
```

Salve e o arquivo será criptografado automaticamente.

### 4. Adicionar Secrets a Outras Máquinas

Para cada máquina adicional:

1. Adicione o módulo `../../modules/services/sops.nix` às imports do host
2. Adicione `../programs/sops.nix` às imports do home-manager do host
3. Configure a chave privada como no passo 2

## Secrets Atuais

- `openroute_token`: Token da API OpenRouteService para pi-agent e opencode

## Adicionar Novos Secrets

1. Edite `secrets/secrets.yaml` com sops
2. Adicione a entrada no módulo `modules/services/sops.nix` na seção `secrets`
3. Atualize `home/programs/sops.nix` para expor como variável de ambiente se necessário