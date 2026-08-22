# nixos-config

Flake for 4 machines — NixOS (`citadel`, `prothean`, `legion`) and nix-darwin (`normandy`).

All three NixOS hosts run the [OpenGamingCollective](https://github.com/OpenGamingCollective/linux) kernel (`modules/ogc-kernel.nix`, currently `v7.2-ogc4` on a stable 7.2.0 base) — the release tag is the kernel tree with their patches applied, fetched from GitHub and built locally. It adds AMD HDMI 2.1 VRR/ALLM (the reason citadel wants it; vanilla 7.2 lacks it) plus gaming-handheld drivers; the Lenovo Legion Go drivers are upstream in vanilla 7.2. Bumps are handled by `scripts/update-ogc-kernel.sh` + the `.github/workflows/check-ogc-update.yml` job, decoupled from nixpkgs's own kernel.

## Linux (NixOS)

```sh
# apply straight from GitHub (no git needed)
sudo nixos-rebuild switch --flake github:tadeucruz/nixos-config#citadel   # or #prothean / #legion

# then clone for local edits
git clone https://github.com/tadeucruz/nixos-config.git ~/nixos-config
```

New machine? Generate the hardware config first: `nixos-generate-config --show-hardware-config > hosts/<name>/hardware-configuration.nix`.

Once installed: `nh os switch` (alias `rebuild`).

## macOS (nix-darwin)

Fresh machine bootstrap:

```sh
# 1. Install Nix: https://nixos.org/download/
# 2. Install Homebrew (required by the homebrew module)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# 3. Rename the /etc files macOS created; nix-darwin manages these
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
# 4. Switch (sudo is required for activation; -H keeps $HOME sane)
sudo -H nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake github:tadeucruz/nixos-config#normandy

# then clone for local edits
git clone https://github.com/tadeucruz/nixos-config.git ~/nixos-config
```

Once installed: `nh darwin switch` (alias `rebuild`).
