# nixos-config

NixOS flakes config for 3 machines:

| Host      | Hardware                                     | Role                                            |
| --------- | --------------------------------------------- | ------------------------------------------------ |
| `citadel` | AMD CPU + GPU                                | Gaming console-like, Steam/gamescope via Jovian + KDE fallback |
| `g15`     | Dell G15 5525 — Ryzen 6800H + Nvidia dGPU   | General-purpose laptop + gaming (KDE, PRIME)    |
| `legion`  | Legion Go — APU AMD Z1 Extreme               | Handheld, Steam/gamescope via Jovian            |

All three run the default NixOS kernel (`linuxPackages_latest`, set in `modules/common.nix`).

## Layout

```
flake.nix              # inputs + 3 nixosConfigurations + Home Manager
modules/
  common.nix           # nix/flakes, BR locale, user, audio, bluetooth, ssh, zram, fwupd
  gaming.nix            # Steam + gamemode + ProtonGE + controllers (citadel + g15 + legion)
  desktop.nix            # full KDE Plasma 6 desktop + printing + Syncthing + Bitwarden (g15 only)
  btrfs-tuning.nix       # shared btrfs mount options + fstrim (citadel + legion)
  jovian.nix              # SteamOS-like gamescope session + KDE fallback (citadel + legion)
hosts/
  citadel/  | g15/  | legion/
    configuration.nix          # per-host system config
    hardware-configuration.nix # ⚠️ regenerate with nixos-generate-config on each machine
home/
  common.nix           # shared dotfiles (git, zsh, starship, firefox)
  desktop.nix          # shared Home Manager config for desktop machines (citadel + g15)
  jovian.nix           # shared Home Manager config for Jovian machines (legion only)
  citadel.nix | g15.nix | legion.nix  # citadel and g15 are identical (common + desktop)
```

## Fresh install — step by step

### 1. Install NixOS

Boot from the NixOS 26.05 ISO and complete the installation normally.

### 2. Clone this repo

```bash
nix-shell -p git --run "git clone <repo-url> ~/nixos-config"
cd ~/nixos-config
```

### 3. Replace the hardware-configuration.nix placeholder

```bash
sudo nixos-generate-config --show-hardware-config \
  > hosts/<host>/hardware-configuration.nix
# host = citadel | g15 | legion
```

### 4. (g15 only) Fix the Nvidia PRIME bus IDs

Find the real bus IDs on this machine:

```bash
lspci | grep -E 'VGA|3D'
# e.g. 06:00.0 -> "PCI:6:0:0" (amdgpu) / 01:00.0 -> "PCI:1:0:0" (nvidia)
```

Update `amdgpuBusId` and `nvidiaBusId` in `hosts/g15/configuration.nix`.

### 5. Apply the config

```bash
sudo nixos-rebuild switch --flake .#<host>
# host = citadel | g15 | legion
```

### 6. Clean up the default NixOS config

Only after the rebuild succeeds:

```bash
sudo rm -rf /etc/nixos
```

### After the first switch

Two shell aliases are available from the repo root:

```bash
rebuild   # apply local config changes
update    # update flake inputs (nixpkgs etc.) and rebuild
```

## Notes

- **Username:** set as `tadeucruz` in `flake.nix` (`username` variable).
- **nixpkgs:** `citadel` and `legion` track `nixos-unstable`; `g15` tracks `nixos-26.05` (stable) since it's used infrequently.
- **legion:** boots directly into Steam/gamescope via Jovian (`jovian.steam.autoStart`), with KDE Plasma 6 available as the "Exit to Desktop" fallback session.
- **citadel:** normal KDE Plasma 6 desktop (same `modules/desktop.nix` + `modules/gaming.nix` as g15), no Jovian. root/`/home`/`/nix` btrfs subvolumes tuned with `compress=zstd`, `noatime`, `space_cache=v2`, `discard=async` (+ weekly `fstrim`); extra `/GAMES` btrfs data drive; `amdgpu.dcfeaturemask=0x400` kernel param enables HDMI 2.1 FRL (VRR itself isn't exposed for HDMI connectors on this driver yet — no `vrr_capable` property).
- **legion:** same btrfs tuning as citadel; controller support via InputPlumber (`services.udev.packages = [ pkgs.inputplumber ]` for the `hid-lenovo-go` udev quirks, since Nix doesn't wire a package's bundled udev rules in automatically) plus decky-loader + LegionGoRemapper for the gamepad remap.
