# Secrets (agenix)

All secrets are encrypted with [agenix](https://github.com/ryantm/agenix) to a
single shared age key. The public key lives in `agenix-rules.nix`; the private
key is stored in Bitwarden.

## Key locations

| Machine | Private key |
| --- | --- |
| normandy (macOS) | `~/.config/age/keys.txt` |
| NixOS hosts | `/etc/age/identity` |

The `agenix` module decrypts to `/run/agenix/<name>` (owned by the target user
when needed). Home Manager only consumes values that are already decrypted at
the system level.

## Editing a secret

```bash
cd secrets
agenix -i ~/.config/age/keys.txt -e openrouter-token.age
```

Replace the placeholder with the real value, save, and the file is re-encrypted
automatically. The `-i` flag is required because this is a native age key
(agenix only auto-detects SSH keys).

## Adding a secret

1. Add the file to `agenix-rules.nix`:
   ```nix
   "my-token.age".publicKeys = [ key ];
   ```
2. Create it:
   ```bash
   cd secrets
   agenix -i ~/.config/age/keys.txt -e my-token.age
   ```
3. Declare it in Nix:
   ```nix
   age.secrets.my-token = {
     file = ../../secrets/my-token.age;
     owner = username;      # only when a user must read it
     mode = "0400";
   };
   ```
4. Reference the runtime path (`config.age.secrets.my-token.path`) instead of
   reading the file during evaluation.

## Current secrets

| File | Runtime path | Notes |
| --- | --- | --- |
| `openrouter-token.age` | `/run/agenix/openrouter-token` | OpenRouter key; written into `~/.local/share/opencode/auth.json` by home-manager activation |
| `cloudflared-token.age` | `/run/agenix/cloudflared-token` | must contain `TUNNEL_TOKEN=...` |
| `forgejo-runner-token.age` | `/run/agenix/forgejo-runner-token` | `TOKEN=<token>` (read as an environment file on omega) |

## First deploy on NixOS

The private key must exist before the first rebuild, otherwise agenix cannot
decrypt:

```bash
sudo install -d -m 700 /etc/age
sudo install -m 600 /dev/stdin /etc/age/identity <<'EOF'
AGE-SECRET-KEY-...
EOF
```

Then `nixos-rebuild switch`. On normandy the launchd daemon reads
`~/.config/age/keys.txt` directly.

## Checking

`agenix -c` only validates SSH recipients, so it reports an error for native
`age1...` keys. Skip it for this repo; the age files are validated when they are
edited or decrypted.
