# nixos-config — agent context

NixOS + nix-darwin flakes repo for 4 machines belonging to Tadeu Cruz (tadeucruz@gmail.com).

## Machines

| Host       | Hardware                                   | Role                                            |
| ---------- | ------------------------------------------ | ------------------------------------------------ |
| `citadel`  | AMD desktop (CPU + GPU)                    | Gaming console-like, Jovian gamescope+Steam + KDE fallback |
| `prothean` | Dell G15 5525 — Ryzen 6800H + Nvidia dGPU | Laptop, full KDE Plasma 6 desktop + gaming, PRIME |
| `legion`   | Legion Go — APU AMD Z1 Extreme             | Handheld, Jovian gamescope+Steam + KDE fallback |
| `normandy` | MacBook Apple Silicon                      | nix-darwin: apps + dotfiles (no gaming) |

## Key decisions already made

- **Jovian on citadel and legion.** gamescope+Steam session (`jovian.steam.autoStart`) with KDE Plasma 6 as the fallback desktop (`modules/jovian.nix`). No display manager — Jovian's `autoStart` manages the session directly. Both also import `modules/gaming.nix` for the generic Steam/controller bits. citadel additionally keeps `hardware.openrgb`, `services.printing`, and the `intl` keyboard variant (carried over from its old desktop-only setup) for when it's "Exit to Desktop"'d out of gamescope.
- **prothean: no Jovian, full KDE desktop.** Uses `modules/desktop.nix` + `modules/gaming.nix` (normal desktop session, SDDM login manager). Has PRIME offload + AWCC fan control (Nvidia dGPU + Dell-specific).
- **normandy: nix-darwin, not NixOS.** System config via `darwinConfigurations.normandy` (`hosts/normandy/configuration.nix` + `modules/common/darwin.nix`). GUI apps via Homebrew casks (`homebrew.onActivation.cleanup = "zap"` → removing a cask from config uninstalls it): bitwarden, betterdisplay. Tailscale and Syncthing via nix-darwin services (`services.tailscale` / a `launchd.user.agents.syncthing`). Firefox is installed from **nixpkgs** (not cask) so the shared `programs.firefox` policies/extensions apply.
- **Kernel: CachyOS on the three NixOS hosts**, via the `nix-cachyos-kernel` flake input (`flake.nix`'s `cachyosKernel` module — pinned overlay + `attic.xuyh0120.win/lantian` binary cache, no local kernel compiling). citadel and prothean use `linuxPackages-cachyos-latest`; legion uses `linuxPackages-cachyos-deckify` (handheld-tuned variant). Dropped the custom OGC-patched kernels (`OpenGamingCollective/linux`) on 2026-08-15 after unexplained hard freezes on legion. legion's Lenovo WMI battery/TDP driver stack (`lenovo_wmi_*`) is present and working on CachyOS too (verified 2026-08-15, not OGC-exclusive). citadel's HDMI VRR is unclear: upstream `CachyOS/linux-cachyos` does carry a VRR/ALLM patch (Lawstorant's `vrr-fixing` branch), but the running build (`v7.1.6-cachyos`, via the third-party `nix-cachyos-kernel` packaging) shows no `vrr_capable` sysfs property on the connected HDMI output — possibly this packaging lags CachyOS's own patch set. Needs re-checking after a `nix-cachyos-kernel` bump.
- **Username:** `tadeucruz` (single variable in `flake.nix`, applies everywhere).
- **nixpkgs channel:** all four machines track `nixos-unstable`. `nixpkgs-stable` input was removed.
- **Home Manager:** integrated into the flake (`home-manager.nixosModules.home-manager` for NixOS, `home-manager.darwinModules.home-manager` for darwin), not standalone.
- **prothean PRIME bus IDs** in `hosts/prothean/configuration.nix` are **placeholders** — must be replaced with real values from `lspci | grep -E 'VGA|3D'` on the machine.
- **`hosts/prothean/hardware-configuration.nix` is still a placeholder** — must be regenerated with `nixos-generate-config` on the physical machine. `hosts/citadel/hardware-configuration.nix` and `hosts/legion/hardware-configuration.nix` are already the real, machine-generated ones. normandy (macOS) has no hardware-configuration.nix.

## File layout

```
flake.nix                        # inputs + mkHost + mkDarwin + 3 nixosConfigurations + 1 darwinConfiguration
modules/
  common/all.nix                 # cross-platform: nix features, allowUnfree, timezone
  common/linux.nix               # NixOS shared: kernel, hardware, services, user, zram
  common/darwin.nix              # nix-darwin shared: homebrew casks, tailscale, syncthing, defaults
  gaming.nix                     # Steam + gamemode + controllers (citadel + prothean + legion)
  jovian.nix                     # gamescope+Steam session + KDE fallback (citadel + legion)
  desktop.nix                    # full KDE Plasma 6 desktop (prothean only)
  btrfs-tuning.nix               # shared btrfs mount options + fstrim (citadel + legion)
hosts/
  <host>/configuration.nix       # per-host system config
  <host>/hardware-configuration.nix  # NixOS only; see placeholder note above
home/
  hosts/<host>.nix               # per-host user overrides (imports home/common + shared modules)
  common/all.nix                 # cross-platform dotfiles: git, zsh, starship, firefox + packages (btop, curl, vim, wget, herdr)
  common/linux.nix               # Linux-only: ryzenadj, KDE sycoca, bitwarden SSH agent, rebuild alias
  common/darwin.nix              # macOS-only: nh + rebuild alias
  development.nix                # dev tooling (vscode, claude-code, opencode, go, godot_4, jdk) — prothean + normandy
  gaming.nix                     # mangohud, protonplus — citadel + prothean + legion
```

## Conventions

- All file content (comments, READMEs, inline notes) must be written in **English**.
- Conversation with the user happens in Portuguese.
- Keep modules flat — avoid deep nesting or extra abstraction layers unless clearly needed.
- Cross-platform user packages belong in `home/common/all.nix`; OS-specific in `home/common/{linux,darwin}.nix`. System `modules/` should not install user apps — that's the `home/` layer's job (only `programs.nh` stays system-level because it wires the `nh clean` GC service).
- `system.stateVersion` is `"26.05"` on the NixOS hosts; normandy uses `system.stateVersion = 7` (nix-darwin).
