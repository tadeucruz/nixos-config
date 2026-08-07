# nixos-config — Claude context

NixOS flakes repo for 3 machines belonging to Tadeu Cruz (tadeucruz@gmail.com).

## Machines

| Host     | Hardware                                   | Role                                        |
| -------- | ------------------------------------------ | -------------------------------------------- |
| `citadel`| AMD desktop (CPU + GPU)                    | Gaming console-like, Jovian gamescope+Steam + KDE fallback (no Jovian-specific hardware quirks, unlike legion) |
| `g15`    | Dell G15 5525 — Ryzen 6800H + Nvidia dGPU | Laptop, full KDE Plasma 6 desktop + gaming, PRIME |
| `legion` | Legion Go — APU AMD Z1 Extreme             | Handheld, Jovian gamescope+Steam + KDE fallback |

## Key decisions already made

- **Jovian on citadel and legion.** gamescope+Steam session (`jovian.steam.autoStart`) with KDE Plasma 6 as the fallback desktop (`modules/jovian.nix`). No display manager — Jovian's `autoStart` manages the session directly. Both also import `modules/gaming.nix` for the generic Steam/controller bits. citadel additionally keeps `hardware.openrgb`, `services.printing`, and the `intl` keyboard variant (carried over from its old desktop-only setup) for when it's "Exit to Desktop"'d out of gamescope.
- **g15: no Jovian, full KDE desktop.** Uses `modules/desktop.nix` + `modules/gaming.nix` (normal desktop session, SDDM login manager). Has PRIME offload + AWCC fan control (Nvidia dGPU + Dell-specific).
- **citadel: CachyOS RC kernel (`nix-cachyos-kernel` input, citadel only).** Carries an out-of-tree HDMI 2.1 VRR/FRL patchset that still hasn't landed in mainline amdgpu — confirmed missing (`vrr_capable` absent on the HDMI connector) even on `linuxPackages_testing` 7.2.0-rc6; upstream is now targeting the Linux 7.3 merge window, not guaranteed. Uses the `release` branch (prebuilt + cached via the `attic.xuyh0120.win/lantian` substituter) to avoid local kernel compiles.
- **legion: no CachyOS kernel.** Uses the default NixOS kernel (`linuxPackages_latest` from `modules/common.nix`). Controller support comes from InputPlumber (`services.udev.packages = [ pkgs.inputplumber ]` for the `hid-lenovo-go` quirks) plus decky-loader + LegionGoRemapper.
- **Username:** `tadeucruz` (single variable in `flake.nix`, applies everywhere).
- **nixpkgs channel:** `citadel` and `legion` track `nixos-unstable`; `g15` tracks `nixos-26.05` (stable, used infrequently).
- **Home Manager:** integrated into the flake (`home-manager.nixosModules.home-manager`), not standalone.
- **g15 PRIME bus IDs** in `hosts/g15/configuration.nix` are **placeholders** — must be replaced with real values from `lspci | grep -E 'VGA|3D'` on the machine.
- **`hosts/g15/hardware-configuration.nix` is still a placeholder** — must be regenerated with `nixos-generate-config` on the physical machine. `hosts/citadel/hardware-configuration.nix` and `hosts/legion/hardware-configuration.nix` are already the real, machine-generated ones.

## File layout

```
flake.nix                      # inputs + mkHost helper + 3 nixosConfigurations
modules/common.nix             # shared: nix settings, locale BR, user, audio, BT, SSH, zram, fwupd
modules/gaming.nix             # Steam + gamemode + controllers (citadel + g15 + legion — session bits handled separately by Jovian)
modules/jovian.nix             # gamescope+Steam session + KDE fallback (citadel + legion)
modules/desktop.nix            # full KDE Plasma 6 desktop (g15 only)
modules/btrfs-tuning.nix       # shared btrfs mount options + fstrim (citadel + legion)
hosts/<host>/configuration.nix # per-host system config
hosts/<host>/hardware-configuration.nix  # see placeholder note above
home/common.nix                # shared dotfiles: git, zsh, starship, firefox, bitwarden SSH agent
home/development.nix           # dev tooling (vscode, claude-code) — citadel + g15 only
home/gaming.nix                # mangohud, protonplus — citadel + g15 + legion
home/<host>.nix                # per-host user overrides
```

## Conventions

- All file content (comments, READMEs, inline notes) must be written in **English**.
- Conversation with the user happens in Portuguese.
- Keep modules flat — avoid deep nesting or extra abstraction layers unless clearly needed.
- `system.stateVersion` is `"26.05"` on all hosts (NixOS 26.05).