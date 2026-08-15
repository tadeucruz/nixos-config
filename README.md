# nixos-config

NixOS flakes config for 3 machines:

| Host      | Hardware                                     | Role                                            |
| --------- | --------------------------------------------- | ------------------------------------------------ |
| `citadel` | AMD CPU + GPU                                | Gaming console-like, Steam/gamescope via Jovian + KDE fallback |
| `prothean`| Dell G15 5525 — Ryzen 6800H + Nvidia dGPU   | General-purpose laptop + gaming (KDE, PRIME)    |
| `legion`  | Legion Go — APU AMD Z1 Extreme               | Handheld, Steam/gamescope via Jovian            |

All three run the CachyOS kernel via the `nix-cachyos-kernel` flake input (binary-cached, no local compiling) — citadel and prothean use `linuxPackages-cachyos-latest`, legion uses the handheld-tuned `linuxPackages-cachyos-deckify`.

## Layout

```
flake.nix              # inputs + 3 nixosConfigurations + Home Manager
modules/
  common.nix           # nix/flakes, BR locale, user, audio, bluetooth, ssh, zram, fwupd
  gaming.nix            # Steam + gamemode + ProtonGE + controllers (citadel + prothean + legion)
  desktop.nix            # full KDE Plasma 6 desktop + printing + Syncthing + Bitwarden (prothean only)
  btrfs-tuning.nix       # shared btrfs mount options + fstrim (citadel + legion)
  jovian.nix              # SteamOS-like gamescope session + KDE fallback (citadel + legion)
hosts/
  citadel/  | prothean/  | legion/
    configuration.nix          # per-host system config
    hardware-configuration.nix # ⚠️ regenerate with nixos-generate-config on each machine
home/
  common.nix           # shared dotfiles (git, zsh, starship, firefox)
  desktop.nix          # shared Home Manager config for desktop machines (citadel + prothean)
  jovian.nix           # shared Home Manager config for Jovian machines (legion only)
  citadel.nix | prothean.nix | legion.nix  # citadel and prothean are identical (common + desktop)
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
# host = citadel | prothean | legion
```

### 4. (prothean only) Fix the Nvidia PRIME bus IDs

Find the real bus IDs on this machine:

```bash
lspci | grep -E 'VGA|3D'
# e.g. 06:00.0 -> "PCI:6:0:0" (amdgpu) / 01:00.0 -> "PCI:1:0:0" (nvidia)
```

Update `amdgpuBusId` and `nvidiaBusId` in `hosts/prothean/configuration.nix`.

### 5. Apply the config

```bash
sudo nixos-rebuild switch --flake .#<host>
# host = citadel | prothean | legion
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
- **nixpkgs:** `citadel`, `legion`, and `prothean` all track `nixos-unstable`.
- **legion:** boots directly into Steam/gamescope via Jovian (`jovian.steam.autoStart`), with KDE Plasma 6 available as the "Exit to Desktop" fallback session.
- **citadel:** boots directly into Steam/gamescope via Jovian, same as legion, with KDE Plasma 6 as the "Exit to Desktop" fallback (`hardware.openrgb`, `services.printing`, and `br`/`abnt2` keyboard kept from its old desktop-only setup for that fallback session). root/`/home`/`/nix` btrfs subvolumes tuned with `compress=zstd`, `noatime`, `space_cache=v2`, `discard=async` (+ weekly `fstrim`); extra `/GAMES` btrfs data drive.
- **legion:** same btrfs tuning as citadel; controller support via InputPlumber (`services.udev.packages = [ pkgs.inputplumber ]` for the `hid-lenovo-go` udev quirks, since Nix doesn't wire a package's bundled udev rules in automatically) plus decky-loader + LegionGoRemapper for the gamepad remap.
