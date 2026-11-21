# SOPS-NIX Secrets Management Guide

## Overview

SOPS (Secrets OPerationS) with sops-nix provides encrypted secrets management for NixOS and nix-darwin systems. Secrets are stored encrypted in Git and decrypted at runtime on target machines.

## Architecture

- **Encryption**: Age encryption with a single key for all machines
- **Storage**: Encrypted YAML files in `secrets/` directory
- **Runtime**: Secrets decrypted to `/run/secrets/` at system activation
- **Environment**: Automatically exposed as environment variables via home-manager

## Initial Setup

### 1. Generate Age Key Pair

```bash
# Generate age key (if not already done)
nix shell nixpkgs#age --command age-keygen -o age-key.txt

# Public key (already in .sops.yaml):
# age1mhp7pdfscyw3v6qqc2twlhz36r64ryqf7sx5g004j84p8f6ps57qzc0lld
```

**IMPORTANT**: Save the private key (from `age-key.txt`) in Bitwarden!

### 2. Deploy Private Key to Each Machine

On each NixOS machine (citadel, prothean, legion, omega):

```bash
mkdir -p ~/.config/sops/age
# Paste private key content from Bitwarden:
vim ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

## Managing Secrets

### Edit Existing Secrets

```bash
# Decrypt, edit, and re-encrypt secrets.yaml
nix shell nixpkgs#sops --command sops secrets/secrets.yaml
```

The file will open in your editor. Edit values, save, and SOPS automatically re-encrypts.

### Add New Secret

1. **Edit secrets file**:
   ```bash
   nix shell nixpkgs#sops --command sops secrets/secrets.yaml
   ```

2. **Add new key-value pair**:
   ```yaml
   # Existing secret
   openroute_token: "existing_token"
   
   # New secret
   github_token: "ghp_your_token_here"
   another_secret: "secret_value"
   ```

3. **Configure in NixOS module** (`modules/services/sops.nix`):
   ```nix
   secrets = {
     openroute_token = { ... };
     
     # Add new secret configuration
     github_token = {
       sopsFile = secretsDir + "/secrets.yaml";
       path = "/run/secrets/github_token";
       mode = "0400";
       owner = config.users.users.tadeucruz.name;
     };
     
     another_secret = {
       sopsFile = secretsDir + "/secrets.yaml";
       path = "/run/secrets/another_secret";
       mode = "0400";
       owner = config.users.users.tadeucruz.name;
     };
   };
   ```

4. **Map to environment variable** (`home/programs/sops.nix`):
   ```nix
   secretMappings = {
     openroute_token = "OPENROUTESERVICE_API_KEY";
     # Add new mappings
     github_token = "GITHUB_TOKEN";
     another_secret = "ANOTHER_SECRET";
   };
   ```

5. **Rebuild and apply**:
   ```bash
   # For main hosts (prothean, citadel, legion)
   nh os switch -H <hostname>
   
   # For omega (stable channel)
   nh os switch -H omega --stable
   ```

## File Structure

```
nixos-config/
├── .sops.yaml                    # SOPS configuration
├── secrets/
│   ├── secrets.yaml              # Encrypted secrets (committed)
│   ├── secrets.template.yaml     # Template for new secrets
│   └── README.md                 # Documentation
├── modules/services/sops.nix     # NixOS module for secrets
└── home/programs/sops.nix        # Home-manager env var mapping
```

## Environment Variables

Secrets are automatically available as environment variables after login:

```bash
# Current mappings:
# openroute_token → OPENROUTESERVICE_API_KEY

echo $OPENROUTESERVICE_API_KEY

# Reload if secrets were updated:
reload-secrets
```

The environment script is at `~/.config/sops/env.sh` and sourced automatically in zsh.

## Verification

### Check Configuration

```bash
# Validate all configurations compile
make check

# Test specific host
nix eval .#nixosConfigurations.prothean.config.system.build.toplevel.drvPath
```

### Verify Secrets Availability

```bash
# Check if secret files exist
ls -la /run/secrets/

# Check environment variables
env | grep OPENROUTESERVICE
```

## Troubleshooting

### Common Issues

1. **"error loading config: no matching creation rules found"**
   - Ensure `.sops.yaml` is in project root with correct `path_regex`

2. **"attribute 'sops' missing" in home-manager**
   - The sops module must be included in NixOS configuration first

3. **Secrets not appearing in /run/secrets/**
   - Check `age.keyFile` path exists with correct permissions
   - Verify secret names match between YAML and Nix configuration

4. **Environment variables not set**
   - Ensure `home/programs/sops.nix` is imported in host's home-manager config
   - Check `~/.config/sops/env.sh` exists and is sourced in zshrc

### Debug Commands

```bash
# Check sops-nix activation
systemctl status sops-nix

# View decrypted secrets (temporary - be careful!)
nix shell nixpkgs#sops --command sops --decrypt secrets/secrets.yaml

# Test age key decryption
echo "test" | nix shell nixpkgs#age --command age -e -r age1mhp7pdfscyw3v6qqc2twlhz36r64ryqf7sx5g004j84p8f6ps57qzc0lld
```

## Security Notes

- **Private key security**: Age private key should only exist in:
  - Bitwarden (master copy)
  - `~/.config/sops/age/keys.txt` on each machine
- **File permissions**: Secrets have `0400` permissions, owned by user
- **Runtime only**: Secrets exist only in `/run/secrets/` (tmpfs)
- **No plaintext in Git**: Only encrypted files are committed

## Adding New Machines

For a new NixOS machine:

1. Add host configuration following existing patterns
2. Include `../../modules/services/sops.nix` in host imports
3. Include `../programs/sops.nix` in home-manager imports
4. Deploy age private key to new machine
5. Rebuild with `nh os switch -H <new-hostname>`

## References

- [SOPS GitHub](https://github.com/mozilla/sops)
- [sops-nix GitHub](https://github.com/Mic92/sops-nix)
- [Age Encryption](https://github.com/FiloSottile/age)