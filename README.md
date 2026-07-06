# nixos-config

NixOS flakes config for 3 machines:

| Host     | Hardware                                    | Role                             | Kernel                              |
| -------- | -------------------------------------------- | --------------------------------- | ------------------------------------ |
| `htpc`   | AMD CPU + GPU                               | HTPC, Steam/gamescope via Jovian | CachyOS RC (`cachyos-rc`)            |
| `g15`    | Dell G15 5525 — Ryzen 6800H + Nvidia dGPU  | General-purpose laptop + gaming  | `linuxPackages_latest` (default)     |
| `legion` | Legion Go — APU AMD Z1 Extreme              | Handheld, Steam/gamescope via Jovian | CachyOS handheld (`cachyos-deckify`) |

## Layout

```
flake.nix              # inputs + 3 nixosConfigurations + Home Manager
modules/
  common.nix           # nix/flakes, BR locale, user, audio, bluetooth, ssh, zram, fwupd
  gaming.nix           # Steam + gamescope + gamemode + ProtonGE + controllers
  desktop.nix          # GNOME/Wayland + AppIndicator + ddcutil + Syncthing + Bitwarden (g15 only)
  jovian.nix           # SteamOS-like gamescope session + KDE fallback (htpc + legion)
hosts/
  htpc/  | g15/  | legion/
    configuration.nix          # per-host system config
    hardware-configuration.nix # ⚠️ regenerate with nixos-generate-config on each machine
home/
  common.nix           # shared dotfiles (git, zsh, starship)
  htpc.nix | g15.nix | legion.nix
```

## CachyOS kernels (htpc, legion)

`htpc` and `legion` use kernel variants from the [xddxdd/nix-cachyos-kernel](https://github.com/xddxdd/nix-cachyos-kernel) flake input (binary-cached `release` branch), via the `cachyosKernel` module in `flake.nix`:

- **htpc** → `cachyos-rc`: carries an out-of-tree HDMI 2.1 VRR/FRL patchset not yet in mainline amdgpu.
- **legion** → `cachyos-deckify`: BORE scheduler + Steam Deck/ROG Ally/MSI Claw HID quirks, tuned for handhelds.
- **g15** intentionally stays on plain `linuxPackages_latest` — it's on the `nixos-26.05` stable channel specifically to stay low-maintenance, so it doesn't carry a CachyOS kernel.

### First rebuild on a fresh install (htpc/legion) — avoid a local kernel compile

The binary cache for `nix-cachyos-kernel` only gets trusted by the Nix daemon *after* a `nixos-rebuild switch` activates the `nix.settings.substituters`/`trusted-public-keys` from `cachyosKernel`. On a from-scratch install, that setting isn't active yet on the very first switch, so Nix would fall back to compiling the kernel locally — slow on htpc, and rough on the Legion Go's limited CPU/RAM.

Pass the cache as a one-off CLI option on that first rebuild so it hits cache immediately instead:

```bash
sudo nixos-rebuild switch --flake .#htpc \
  --option extra-substituters "https://attic.xuyh0120.win/lantian" \
  --option extra-trusted-public-keys "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
# host = htpc | legion
```

After this first switch, the substituter is already in `/etc/nix/nix.conf` and subsequent `nixos-rebuild switch`/`rebuild` calls hit cache normally without the extra flags.

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
# host = htpc | g15 | legion
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
# host = htpc | g15 | legion
# htpc/legion: see "First rebuild" above re: the CachyOS binary cache.
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
- **nixpkgs:** `htpc` and `legion` track `nixos-unstable`; `g15` tracks `nixos-26.05` (stable) since it's used infrequently.
- **htpc / legion:** boot directly into Steam/gamescope via Jovian (`jovian.steam.autoStart`), with KDE Plasma 6 available as the "Exit to Desktop" fallback session.
- **htpc:** root/`/home`/`/nix` btrfs subvolumes tuned with `compress=zstd`, `noatime`, `space_cache=v2`, `discard=async` (+ weekly `fstrim`); extra `/mnt/GAMES` btrfs data drive; `amdgpu.dcfeaturemask=0x400` kernel param enables HDMI 2.1 FRL (VRR itself isn't exposed for HDMI connectors on this driver yet — no `vrr_capable` property).
- **legion:** same btrfs tuning as htpc; default kernel replaced by `cachyos-deckify` (see above); custom udev rules + `systemd.services.inputplumber` ordering work around `hid_lenovo_go` boot-time HID rebind races.
