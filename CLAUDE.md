# nixos-config — Claude context

NixOS flakes repo for 3 machines belonging to Tadeu Cruz (tadeucruz@gmail.com).

## Machines

| Host     | Hardware                                   | Role                                        |
| -------- | ------------------------------------------ | -------------------------------------------- |
| `citadel`| AMD desktop (CPU + GPU)                    | Gaming console-like, Jovian gamescope+Steam + KDE fallback (no Jovian-specific hardware quirks, unlike legion) |
| `prothean`| Dell G15 5525 — Ryzen 6800H + Nvidia dGPU | Laptop, full KDE Plasma 6 desktop + gaming, PRIME |
| `legion` | Legion Go — APU AMD Z1 Extreme             | Handheld, Jovian gamescope+Steam + KDE fallback |

## Key decisions already made

- **Jovian on citadel and legion.** gamescope+Steam session (`jovian.steam.autoStart`) with KDE Plasma 6 as the fallback desktop (`modules/jovian.nix`). No display manager — Jovian's `autoStart` manages the session directly. Both also import `modules/gaming.nix` for the generic Steam/controller bits. citadel additionally keeps `hardware.openrgb`, `services.printing`, and the `intl` keyboard variant (carried over from its old desktop-only setup) for when it's "Exit to Desktop"'d out of gamescope.
- **prothean: no Jovian, full KDE desktop.** Uses `modules/desktop.nix` + `modules/gaming.nix` (normal desktop session, SDDM login manager). Has PRIME offload + AWCC fan control (Nvidia dGPU + Dell-specific).
- **citadel: NixOS's own `linuxPackages_testing` with the official HDMI 2.1 VRR/ALLM patch series applied (`hosts/citadel/kernel-vrr.nix`, citadel only).** Current upstream series: `[PATCH v2 0/4] HDMI 2.1 VRR and ALLM support`, Fangzhi Zuo (AMD), https://lists.freedesktop.org/archives/amd-gfx/2026-August/150041.html (v1: https://lore.kernel.org/amd-gfx/20260730171754.704049-1-jerry.zuo@amd.com/) — posted upstream, missed the 7.2 merge window, and — confirmed 2026-08-10 — also missed 7.3 after AMD's last DRM-Next feature pull for that cycle already went out; now targeting Linux 7.4, expected end of 2026. The series targets AMD's `amd-staging-drm-next` branch, which has already split `amdgpu_dm.c` into separate files not present on mainline yet — `patches/amdgpu-hdmi21-vrr-allm/` holds the patches as posted (for reference), `patches/amdgpu-hdmi21-vrr-allm-testing-kernel/` holds the same logic hand-ported to apply against `linux_testing`'s still-monolithic `amdgpu_dm.c` (see that directory's `0004` patch header for exactly what was ported and why one debug-log-only hunk was dropped). Built fully locally — no binary cache, since applying out-of-tree patches means it's not the exact `linuxPackages_testing` nixpkgs already caches. **Known issue:** hangs on every shutdown/reboot — confirmed (2026-08-10) to be an upstream RC-track regression, not something the VRR patches cause; nixpkgs' own vanilla `linuxPackages_testing` (unpatched) hangs identically. Accepted tradeoff since the hang happens either way.
- **legion: default NixOS kernel.** Uses `linuxPackages_latest` from `modules/common.nix`, no custom kernel. Controller support comes from InputPlumber (`services.udev.packages = [ pkgs.inputplumber ]` for the `hid-lenovo-go` quirks) plus decky-loader + LegionGoRemapper.
- **Username:** `tadeucruz` (single variable in `flake.nix`, applies everywhere).
- **nixpkgs channel:** all three machines (`citadel`, `prothean`, `legion`) track `nixos-unstable`. `nixpkgs-stable` input was removed.
- **Home Manager:** integrated into the flake (`home-manager.nixosModules.home-manager`), not standalone.
- **prothean PRIME bus IDs** in `hosts/prothean/configuration.nix` are **placeholders** — must be replaced with real values from `lspci | grep -E 'VGA|3D'` on the machine.
- **`hosts/prothean/hardware-configuration.nix` is still a placeholder** — must be regenerated with `nixos-generate-config` on the physical machine. `hosts/citadel/hardware-configuration.nix` and `hosts/legion/hardware-configuration.nix` are already the real, machine-generated ones.

## File layout

```
flake.nix                      # inputs + mkHost helper + 3 nixosConfigurations
modules/common.nix             # shared: nix settings, locale BR, user, audio, BT, SSH, zram, fwupd
modules/gaming.nix             # Steam + gamemode + controllers (citadel + prothean + legion — session bits handled separately by Jovian)
modules/jovian.nix             # gamescope+Steam session + KDE fallback (citadel + legion)
modules/desktop.nix            # full KDE Plasma 6 desktop (prothean only)
modules/btrfs-tuning.nix       # shared btrfs mount options + fstrim (citadel + legion)
hosts/<host>/configuration.nix # per-host system config
hosts/<host>/hardware-configuration.nix  # see placeholder note above
home/common.nix                # shared dotfiles: git, zsh, starship, firefox, bitwarden SSH agent
home/development.nix           # dev tooling (vscode, claude-code) — citadel + prothean only
home/gaming.nix                # mangohud, protonplus — citadel + prothean + legion
home/<host>.nix                # per-host user overrides
```

## Conventions

- All file content (comments, READMEs, inline notes) must be written in **English**.
- Conversation with the user happens in Portuguese.
- Keep modules flat — avoid deep nesting or extra abstraction layers unless clearly needed.
- `system.stateVersion` is `"26.05"` on all hosts (NixOS 26.05).