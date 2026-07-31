# nixos-config — Claude context

NixOS flakes repo for 3 machines belonging to Tadeu Cruz (tadeucruz@gmail.com).

## Machines

| Host     | Hardware                                   | Role                                        |
| -------- | ------------------------------------------ | -------------------------------------------- |
| `citadel`| AMD desktop (CPU + GPU)                    | Gaming PC, full KDE Plasma 6 desktop (like g15, no Jovian) |
| `g15`    | Dell G15 5525 — Ryzen 6800H + Nvidia dGPU | Laptop, full KDE Plasma 6 desktop + gaming, PRIME |
| `legion` | Legion Go — APU AMD Z1 Extreme             | Handheld, Jovian gamescope+Steam + KDE fallback |

## Tooling

- This Mac has no local Nix install, but Docker Desktop is installed. Run Nix commands (e.g. `nix flake lock`) via:
  ```
  docker run --rm -v "$PWD":/repo -w /repo nixos/nix:latest \
    nix --extra-experimental-features 'nix-command flakes' flake lock
  ```

## Key decisions already made

- **Jovian on legion only.** gamescope+Steam session (`jovian.steam.autoStart`) with KDE Plasma 6 as the fallback desktop (`modules/jovian.nix`). No display manager — Jovian's `autoStart` manages the session directly.
- **citadel and g15: no Jovian, full KDE desktop.** Both use `modules/desktop.nix` + `modules/gaming.nix` (normal desktop session, SDDM login manager). g15 additionally has PRIME offload + AWCC fan control (Nvidia dGPU + Dell-specific).
- **legion: no CachyOS kernel.** Uses the default NixOS kernel (`linuxPackages_latest` from `modules/common.nix`). Controller support comes from InputPlumber (`services.udev.packages = [ pkgs.inputplumber ]` for the `hid-lenovo-go` quirks) plus decky-loader + LegionGoRemapper.
- **Username:** `tadeucruz` (single variable in `flake.nix`, applies everywhere).
- **nixpkgs channel:** `citadel` and `legion` track `nixos-unstable`; `g15` tracks `nixos-26.05` (stable, used infrequently).
- **Home Manager:** integrated into the flake (`home-manager.nixosModules.home-manager`), not standalone.
- **g15 PRIME bus IDs** in `hosts/g15/configuration.nix` are **placeholders** — must be replaced with real values from `lspci | grep -E 'VGA|3D'` on the machine.
- **`hosts/g15/hardware-configuration.nix` and `hosts/legion/hardware-configuration.nix` are placeholders** — must be regenerated with `nixos-generate-config` on each physical machine. `hosts/citadel/hardware-configuration.nix` is already the real, machine-generated one.

## File layout

```
flake.nix                      # inputs + mkHost helper + 3 nixosConfigurations
modules/common.nix             # shared: nix settings, locale BR, user, audio, BT, SSH, zram, fwupd
modules/gaming.nix             # Steam + gamemode + controllers (citadel + g15 — legion gets Steam via Jovian)
modules/jovian.nix             # gamescope+Steam session + KDE fallback (legion only)
modules/desktop.nix            # full KDE Plasma 6 desktop (citadel + g15)
hosts/<host>/configuration.nix # per-host system config
hosts/<host>/hardware-configuration.nix  # see placeholder note above
home/common.nix                # shared dotfiles: git, zsh, starship, firefox
home/jovian.nix                # shared Home Manager config for Jovian machines (legion only)
home/<host>.nix                # per-host user overrides
```

## Conventions

- All file content (comments, READMEs, inline notes) must be written in **English**.
- Conversation with the user happens in Portuguese.
- Keep modules flat — avoid deep nesting or extra abstraction layers unless clearly needed.
- `system.stateVersion` is `"26.05"` on all hosts (NixOS 26.05).

## Pending tasks

1. Replace `hosts/g15/hardware-configuration.nix` and `hosts/legion/hardware-configuration.nix` with output of `nixos-generate-config` on each machine.
2. Fix g15 PRIME bus IDs in `hosts/g15/configuration.nix`.
