# nixos-config — agent context

NixOS + nix-darwin flakes repo for 4 machines belonging to Tadeu Cruz (tadeucruz@gmail.com).

## Machines

| Host       | Hardware                                   | Role                                            |
| ---------- | ------------------------------------------ | ------------------------------------------------ |
| `citadel`  | AMD desktop (CPU + GPU)                    | Gaming console-like, Jovian gamescope+Steam + KDE fallback |
| `prothean` | Dell G15 5525 — Ryzen 6800H + Nvidia dGPU | Laptop, full KDE Plasma 6 desktop + gaming, PRIME |
| `legion`   | Legion Go — APU AMD Z1 Extreme             | Handheld, Jovian gamescope+Steam + KDE fallback |
| `omega`    | Home server (x86_64, VT-x/AMD-V)           | Headless NAS + containers + VMs, **NixOS stable** |
| `normandy` | MacBook Apple Silicon                      | nix-darwin: apps + dotfiles (no gaming) |

## Key decisions

- **Jovian on citadel and legion** (`modules/jovian.nix`): gamescope+Steam (`jovian.steam.autoStart`) with KDE Plasma 6 fallback, no display manager. Both also import `modules/gaming.nix`.
  - **citadel HDR fix**: Jovian's `gamescope-session` omits `--hdr-enabled` (HDR looks washed out). Fixed via a `gamescope` shim in `hosts/citadel/configuration.nix` that injects `--hdr-enabled` then re-execs `/run/wrappers/bin/gamescope`, wired through `/etc/jovian/gamescope-session/pre-start`. Verified with Cyberpunk 2077. citadel only.
  - **Jovian steam-launcher hardcodes its steam package**, so `STEAM_EXTRA_COMPAT_TOOLS_PATHS` never reaches Steam on citadel/legion. Fix in `modules/jovian.nix`: injected via `jovian.steam.environment` → `/etc/xdg/gamescope-session/environment` → `%t/gamescope-environment` → `steam-launcher.service` EnvironmentFile.
- **prothean: no Jovian, full KDE desktop** (`modules/desktop.nix` + `modules/gaming.nix`, SDDM). PRIME offload + AWCC fan control.
- **omega: NixOS stable, headless server** (`modules/server/`, no home-manager/flatpak — `mkServer` helper in `flake.nix`, tracks `nixpkgs-stable` = `nixos-26.05`). Migrated from Proxmox. `modules/server/` holds only generic infrastructure; workloads (VMs, LXCs, services) live in `modules/server/services/`:
  - **Samba + NTFS** (`modules/server/services/samba.nix`) replaces OMV. NTFS disks mounted in-kernel via `ntfs3` (no ntfs-3g). The `fileSystems` mounts live in `hosts/omega/configuration.nix` (host-specific storage, same pattern as citadel's `/GAMES`); `samba.nix` only exports the SMB shares. UUIDs are placeholders — fill via `blkid`; SMB password set once with `smbpasswd -a tadeucruz`.
  - **Podman + Quadlet** (`modules/server/podman.nix`) replaces the Docker Compose stacks. `dockerCompat` + `dockerSocket` + `podman-compose` keep old compose files working while services are ported to quadlet units (declared via `environment.etc."containers/systemd/..."`, since there's no `virtualisation.quadlet` option on nixos-26.05).
  - **HAOS as a libvirt VM** (`modules/server/services/haos.nix`): qcow2 pinned via `fetchurl` (version + sha256 are TODO), decompressed on first boot, domain XML declared in the repo (bridge `br0` — TODO: create the bridge on the host). HAOS is an appliance, must stay a VM. The `haos-vm` service is idempotent — the qcow2 (HAOS configs) is only written once; `virsh define` only applies the hardware definition. Depends on generic `modules/server/libvirt.nix` (asserted).
  - **HermesAgent as LXC** (`modules/server/services/hermesagent.nix`): classic LXC (`virtualisation.lxc`), Debian bookworm via download template, created on first boot by a oneshot service, autostarted by `lxc.service`. Rootfs is imperative (apk/apt inside). lxcbr0 bridge via `lxc-net.service`. Depends on generic `modules/server/lxc.nix` (asserted).
  - **cloudflared as a host systemd service** (`modules/server/services/cloudflared.nix`): remotely-managed tunnel (token-based), so nixpkgs' `services.cloudflared.tunnels` (credentials-file) doesn't apply — custom unit reads `TUNNEL_TOKEN` from `/etc/cloudflared/token` (outside git). `DynamicUser` + hardening.
  - `hosts/omega/hardware-configuration.nix` is a placeholder — regenerate with `nixos-generate-config`.
- **normandy: nix-darwin** (`darwinConfigurations.normandy`), split into reusable baseline + normandy-only so a future Mac can import just the baseline: `modules/common/darwin.nix` (touch ID sudo, Nerd Font, Tailscale, Syncthing, defaults) + `modules/normandy.nix` (dock persistent-apps, displayplacer "More Space" scaling, Xcode postActivation). Homebrew has no home-manager equivalent, so it gets its own top-level `homebrew/` dir: `common.nix` (bootstrap), `normandy.nix` (personal/hardware), `development-mac.nix` (mobile dev toolchain). Firefox from nixpkgs (not cask) so shared `programs.firefox` policies apply. `.github/workflows/check.yml` validates evaluation of all configurations on Ubuntu.
- **Kernel: OGC only on citadel, vanilla `linuxPackages_latest` on legion + prothean.** citadel's `modules/ogc-kernel.nix` starts from nixpkgs's `linux_latest` and appends OGC's `monolithic.patch` (currently `v7.2-ogc9`) via `kernelPatches`; only the patch asset is `fetchurl`'d (never `fetchzip` of OGC's git archive — unpacked-tree hash varies by nix version). Buys citadel: **AMD HDMI 2.1 VRR/ALLM** + harmless handheld drivers. legion/prothean stay on the same stock `linux_latest` (everything from cache.nixos.org). Bumps via `scripts/update.sh ogc` (patch hash only; base follows `linux_latest`), surfaced by `check-updates.yml`. **Base-match guard:** `scripts/update.sh` compares the OGC tag's base (`v7.2.1-ogc3` → `7.2.1`) against the real `linux_latest` version and **skips the bump with a warning** while they differ — the OGC patch may not apply on a mismatched base (a `v7.2.1-ogc2` bump once broke citadel's build: `hid-asus.c` hunk failed). The bump applies automatically on a later cron once nixpkgs's `linux_latest` reaches the OGC base. `scripts/update.sh` runs `flake` first so the guard evaluates the kernel version from the freshly-updated `flake.lock` (a new `linux_latest` can trigger the OGC bump in the same run).
- **Two Proton flavors, pinned to latest upstream, auto-bumped by CI.** `programs.steam.extraCompatPackages` ships **GE-Proton** (`modules/proton-ge.nix`) and **Proton-CachyOS** (`modules/proton-cachyos.nix`), both `fetchurl` + `tar` with a `steamcompattool` output (`--strip-components=1`). Bumps via `scripts/update.sh ge|cachyos`, surfaced by `check-updates.yml`. `version = "latest"` keeps store paths `proton-ge-latest`/`proton-cachyos-latest`. **Why not `pkgs.proton-ge-bin`:** GE-Proton11-3 aborts on `icuuc.dll.u_setMemoryFunctions_65` (upstream #651, fixed 11-4); pinned 11-5 + CachyOS 11.0 avoid it. **FSR4 upgrade:** `home/gaming.nix` sets `PROTON_FSR4_UPGRADE=1` — auto-downloads `amdxcffx64.dll`, upgrades FSR 3.1 → FSR 4. Only effective with Proton-CachyOS + RDNA4 (citadel); harmless elsewhere.
- **legion: InputPlumber + SteamOS-Manager stack** (`hosts/legion/configuration.nix`), aligned with Bazzite 44. `services.inputplumber.enable = true` with udev rules; `hid_lenovo_go` loaded. **TDP via Steam QAM → SteamOS-Manager → amd-pmf** (validated 8→20→30W). `jovian.decky-loader` re-enabled for the **LegionGoRemapper** plugin only (button remap); SimpleDeckyTDP is gone. **scx_lavd scheduler** enabled on boot via `systemd.services.scx.wantedBy = lib.mkOverride 0 [ "multi-user.target" ]` (Jovian's `mkForce []` bypassed).
  - **TDP sysfs inspection**:
    - Lenovo WMI firmware attributes (watts): `/sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/{ppt_pl1_spl,ppt_pl2_sppt,ppt_pl3_fppt,ppt_cpu_cl}/current_value`
    - Platform profile: `/sys/class/platform-profile/platform-profile-1/profile` (`lenovo-wmi-gamezone`: `low-power`, `balanced`, `performance`, `custom`)
    - One-liner to query state: `ssh legion.local 'for f in /sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/*/current_value; do [ -f "$f" ] && echo "$(basename $(dirname $f)): $(cat $f)"; done; cat /sys/class/platform-profile/*/profile 2>/dev/null'`
  - **History**: HHD was a previous stack (commit `a20ef09`); gyro/RGB/fan-curves lost with InputPlumber but Tadeu doesn't care about gyro. **Future check on nixpkgs bumps:** InputPlumber/PowerStation maturity on the original Legion Go.
- **Username:** `tadeucruz` (single variable in `flake.nix`).
- **`result*` is gitignored** — `nix build` at the root leaves a `result` symlink into the store.
- **nixpkgs channel:** desktop/laptop machines track `nixos-unstable`; omega tracks `nixos-26.05` (stable) via the `nixpkgs-stable` input.
- **Home Manager:** integrated into the flake, not standalone.
- **Neovim (LazyVim), meant to eventually replace VSCode** — prothean + normandy only (`home/neovim.nix`). Config from `LazyVim/starter`, deployed read-only via `xdg.configFile.nvim.source`; only `lang.java`/`lang.go` extras enabled. `lockfile` redirected to `stdpath("data")`; LSP servers left to Mason (not nix) due to Mason's install layout.
- **prothean PRIME bus IDs** in `hosts/prothean/configuration.nix` are **placeholders** — replace with real `lspci | grep -E 'VGA|3D'` values.
- **`hosts/prothean/hardware-configuration.nix` is a placeholder** — regenerate with `nixos-generate-config`. citadel/legion are real; normandy has none.

## File layout

```
flake.nix                        # inputs + mkHost + mkDarwin + 3 nixosConfigurations + 1 darwinConfiguration
modules/
  common/all.nix                 # cross-platform: nix features, allowUnfree, timezone
  common/linux.nix               # NixOS shared: kernel, hardware, services, user, zram
  common/darwin.nix              # nix-darwin shared baseline (any Mac): touch ID sudo, fonts, tailscale, syncthing, defaults
  normandy.nix                   # normandy-only: dock persistent-apps, displayplacer/Xcode postActivation (personal, not dev)
  gaming.nix                     # Steam + gamemode + controllers (citadel + prothean + legion)
  jovian.nix                     # gamescope+Steam session + KDE fallback (citadel + legion)
  desktop.nix                    # full KDE Plasma 6 desktop (prothean only)
  btrfs-tuning.nix               # shared btrfs mount options + fstrim (citadel + legion)
  server/
    base.nix                     # headless server subset of common/linux.nix (no desktop bits)
    libvirt.nix                  # generic libvirt/KVM infra (libvirtd + qemu_kvm)
    lxc.nix                      # generic LXC infra (lxc + lxc-net bridge + autostart)
    podman.nix                   # Podman + Quadlet infra — replaces Docker Compose
    services/                    # workloads: VMs, LXCs, and host services
      samba.nix                  # Samba + NTFS mounts (ntfs3) — replaces OMV
      cloudflared.nix            # Cloudflare Tunnel (token-based, host systemd service)
      haos.nix                   # HAOS VM (qcow2 pinned + domain XML) — needs libvirt.nix
      hermesagent.nix            # HermesAgent LXC container — needs lxc.nix
homebrew/                        # no home-manager equivalent → top-level dir, split like modules/
  common.nix                     # bootstrap (enable, cleanup mode, taps) — any Mac
  normandy.nix                   # normandy-only personal/hardware (not dev): displayplacer, cryptomator, WhatsApp
  development-mac.nix            # normandy-only mobile dev toolchain: cocoapods, android-studio, flutter, Xcode
hosts/
  <host>/configuration.nix       # per-host system config
  <host>/hardware-configuration.nix  # NixOS only; see placeholder note above
home/
  hosts/<host>.nix               # per-host user overrides
  common/all.nix                 # cross-platform dotfiles: git, zsh, starship, firefox + packages
  common/linux.nix               # Linux-only: KDE sycoca, bitwarden SSH agent, rebuild alias
  common/darwin.nix              # macOS-only: nh (programs.nh, with GC) + rebuild alias
  development.nix                # dev tooling (vscode, claude-code, opencode, go, godot_4, jdk) — prothean + normandy
  neovim.nix                     # LazyVim (java + go extras) — prothean + normandy
  neovim/                        # nvim config copied to ~/.config/nvim
  gaming.nix                     # mangohud, steam extraCompatPackages (pinned GE-Proton + Proton-CachyOS)
```

## Conventions

- All file content (comments, READMEs, inline notes) in **English**.
- Conversation with the user in Portuguese.
- Keep modules flat — avoid deep nesting or extra abstraction unless clearly needed.
- Cross-platform user packages in `home/common/all.nix`; OS-specific in `home/common/{linux,darwin}.nix`. System `modules/` should not install user apps — that's `home/`'s job. `programs.nh` is system-level on NixOS (wires the `nh clean` GC service) but `home/common/darwin.nix` on darwin. **Note:** `programs.nh.clean` uses a systemd timer, which macOS ignores → darwin replaces it with a `launchd.agents.nh-clean` job (same args).
- `system.stateVersion` is `"26.05"` on NixOS; normandy uses `7` (nix-darwin).
- Any `homebrew.*` option goes under `homebrew/`, never `modules/` or `home/`. Split like `modules/`: `common.nix` baseline + per-purpose files.
