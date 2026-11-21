# Secrets Management with SOPS-nix

## Initial Setup

### 1. Generate Age Key (if not done yet)

```bash
nix shell nixpkgs#age --command age-keygen -o age-key.txt
```

**Save the private key in Bitwarden!**

Generated public key: `age1mhp7pdfscyw3v6qqc2twlhz36r64ryqf7sx5g004j84p8f6ps57qzc0lld`

### 2. Configure Private Key on Machines

On each NixOS machine (citadel, prothean, legion, omega):

```bash
mkdir -p ~/.config/sops/age
# Paste the content of age-key.txt (private key) into:
vim ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

### 3. Edit Secrets

To add/edit secrets:

```bash
# Install sops temporarily
nix shell nixpkgs#sops --command sops secrets/secrets.yaml
```

In the editor that opens, add/edit values:

```yaml
openroute_token: "your_token_here"
# other_secrets: "values"
```

Save and the file will be automatically encrypted.

### 4. Add Secrets to Other Machines

For each additional machine:

1. Add the module `../../modules/services/sops.nix` to host imports
2. Add `../programs/sops.nix` to the host's home-manager imports
3. Configure the private key as in step 2

## Current Secrets

- `openroute_token`: OpenRouteService API token for pi-agent and opencode

## Adding New Secrets

1. Edit `secrets/secrets.yaml` with sops
2. Add entry in `modules/services/sops.nix` module in the `secrets` section
3. Update `home/programs/sops.nix` to expose as environment variable if needed