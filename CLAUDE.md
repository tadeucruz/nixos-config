# nixos-config — Claude context

NixOS flakes repo for 3 machines belonging to Tadeu Cruz (tadeucruz@gmail.com).

## Machines

| Host     | Hardware                                   | Role                              |
| -------- | ------------------------------------------ | --------------------------------- |
| `htpc`   | AMD desktop (CPU + GPU)                    | HTPC, SteamOS-like (no Jovian)    |
| `g15`    | Dell G15 5525 — Ryzen 6800H + Nvidia dGPU | Laptop, GNOME + gaming, PRIME     |
| `legion` | Legion Go — APU AMD Z1 Extreme             | Handheld, stock kernel + HHD      |

## Key decisions already made

- **No Jovian on htpc or g15.** htpc uses greetd autologin into gamescope+Steam (Big Picture). g15 uses full GNOME desktop with PRIME offload.
- **Legion Go: no Jovian for now.** Using stock kernel + `services.handheld-daemon`. Jovian input is commented out in `flake.nix` — enable if hardware support proves insufficient.
- **Username:** `tadeu` (single variable in `flake.nix`, applies everywhere).
- **nixpkgs channel:** `nixos-unstable`.
- **Home Manager:** integrated into the flake (`home-manager.nixosModules.home-manager`), not standalone.
- **g15 PRIME bus IDs** in `hosts/g15/configuration.nix` are **placeholders** — must be replaced with real values from `lspci | grep -E 'VGA|3D'` on the machine.
- **All 3 `hardware-configuration.nix` files are placeholders** — must be regenerated with `nixos-generate-config` on each physical machine.

## File layout

```
flake.nix                      # inputs + mkHost helper + 3 nixosConfigurations
modules/common.nix             # shared: nix settings, locale BR, user, audio, BT, SSH
modules/gaming.nix             # Steam + gamescope + gamemode + controllers (htpc + legion + g15)
modules/desktop.nix            # GNOME/Wayland (g15 only)
hosts/<host>/configuration.nix # per-host system config
hosts/<host>/hardware-configuration.nix  # PLACEHOLDER
home/common.nix                # shared dotfiles: git, zsh, starship
home/<host>.nix                # per-host user overrides
```

## Conventions

- All file content (comments, READMEs, inline notes) must be written in **English**.
- Conversation with the user happens in Portuguese.
- Keep modules flat — avoid deep nesting or extra abstraction layers unless clearly needed.
- `system.stateVersion` is `"26.05"` on all hosts (NixOS 26.05).

## Pending tasks

1. Replace `hosts/*/hardware-configuration.nix` with output of `nixos-generate-config` on each machine.
2. Fix g15 PRIME bus IDs in `hosts/g15/configuration.nix`.
3. Decide whether to enable Jovian on the Legion Go (input already in `flake.nix`, commented out).
4. Confirm `services.handheld-daemon` exists in the nixpkgs revision in use (recent unstable required).
