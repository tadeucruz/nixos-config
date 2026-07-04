# nixos-config

NixOS flakes config for 3 machines:

| Host     | Hardware                                    | Role                            |
| -------- | ------------------------------------------- | ------------------------------- |
| `htpc`   | AMD CPU + GPU                               | HTPC, Steam/gamescope session   |
| `g15`    | Dell G15 5525 — Ryzen 6800H + Nvidia dGPU  | General-purpose laptop + gaming |
| `legion` | Legion Go — APU AMD Z1 Extreme              | Handheld                        |

## Layout

```
flake.nix              # inputs + 3 nixosConfigurations + Home Manager
modules/
  common.nix           # nix/flakes, BR locale, user, audio, bluetooth, ssh, zram
  gaming.nix           # Steam + gamescope + gamemode + ProtonGE + controllers
  desktop.nix          # GNOME/Wayland + AppIndicator + ddcutil + Syncthing + Bitwarden (g15 only)
hosts/
  htpc/  | g15/  | legion/
    configuration.nix          # per-host system config
    hardware-configuration.nix # ⚠️ PLACEHOLDER — generate on each machine
home/
  common.nix           # shared dotfiles (git, zsh, starship)
  htpc.nix | g15.nix | legion.nix
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
- **htpc / legion:** boot directly into Steam/gamescope via `greetd` autologin (SteamOS-like, no Jovian).
- **legion:** stock kernel + `handheld-daemon`. Jovian input is prepared and commented out in `flake.nix` — enable if hardware support proves insufficient.
