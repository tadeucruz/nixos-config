# EAC Linux v2 readiness

Tracking of [Easy Anti-Cheat Linux v2](https://onlineservices.epicgames.com/news/introducing-easy-anti-cheat-linux-v2)
requirements across hosts.

EAC v2 requires 8 cumulative system features. This file tracks which are
enabled, which are skipped, and why.

## Requirements

| # | Requirement | Status | How / Why |
|---|---|---|---|
| 1 | Signed kernel & modules (well-known key) | ❌ Not enabled | Needs a key from EAC's well-known list (Canonical, Fedora, Debian, openSUSE, Universal Blue, Microsoft UEFI CA, ...). NixOS is not on the list yet. Own keys (lanzaboote / custom MOK) do not count. |
| 2 | TPM 2.0 | ✅ Enabled | `security.tpm2.enable = true` via `modules/desktop/tpm2.nix`. Hardware must have TPM 2.0 enabled in BIOS. |
| 3 | Secure Boot | ❌ Not enabled | Deliberately skipped for now. Would also require a well-known key (same blocker as #1). |
| 4 | Measured boot | ⚠️ Partial | systemd-boot measures into TPM PCRs by default, but without Secure Boot (#3) EAC may not accept the attestation. |
| 5 | IOMMU | ✅ Enabled | `amd_iommu=on` in `modules/boot/base.nix` (all hosts are AMD). Also enable IOMMU in BIOS. |
| 6 | Kernel lockdown integrity | ✅ Enabled | `lockdown=integrity` in `modules/boot/base.nix`. |
| 7 | Kexec disabled | ✅ Enabled | `kexec_load_disabled=1` in `modules/boot/base.nix`. |
| 8 | BPF LSM | ✅ Enabled | `lsm=...,bpf` + `boot.kernelModules = [ "bpf" ]` in `modules/boot/base.nix`. |

**Score: 5 / 8 enabled** (1, 3 blocked by well-known key requirement; 4 partial without Secure Boot).

## Per-host status

| Host | TPM2 | IOMMU/lockdown/kexec/BPF | Score | Notes |
|---|---|---|---|---|
| `citadel` | ✅ | ✅ | 5/8 | AMD GPU + OGC kernel. Verify `lockdown=integrity` works with the OGC patch after rebuild. |
| `legion` | ✅ | ✅ | 5/8 | Jovian/gamescope + `scx_lavd` (BPF scheduler) — verify no conflict with BPF LSM after rebuild. |
| `omega` | ✅ | ✅ | 5/8 | Headless server. Libvirt PCI passthrough still fine with `amd_iommu=on` (does not disable passthrough). |
| `prothean` | ⏳ Pending | ⏳ Pending | — | Deferred: NVIDIA out-of-tree driver + `acpi_call` + AWCC conflict with `lockdown=integrity`. Needs physical access to test. |
| `normandy` | N/A | N/A | — | macOS / nix-darwin, out of scope. |

## What is intentionally NOT enabled

- **Secure Boot (#3):** skipped by decision. Even if enabled, own keys are
  rejected — EAC requires a well-known key in the UEFI db / MOK.
- **Well-known signed kernel (#1):** blocked until either NixOS is added to
  EAC's well-known list (contact: `linux-gaming@epicgames.com`) or the kernel
  is signed with a key from a distro already on the list (Fedora/Debian/etc).
- **prothean lockdown/IOMMU/TPM2:** postponed — lockdown breaks NVIDIA MSR
  writes and `acpi_call`; needs hands-on testing.

## Next steps to reach 8/8

1. Watch for NixOS joining EAC's well-known key list (or sign with a
   Fedora/Debian key).
2. Enable Secure Boot with that well-known key (likely via shim, not
   lanzaboote — own keys don't count).
3. Enable lockdown/IOMMU/TPM2 on prothean once it can be tested physically.
4. Re-verify measured boot (#4) once Secure Boot is on.

## Rebuild notes

- `kernelParams` lists are concatenated across modules (base + gaming + host),
  not overwritten.
- After rebuild, check before reboot: `cat /proc/cmdline` should contain
  `lockdown=integrity kexec_load_disabled=1 ... bpf`.
- After reboot, verify: `cat /sys/kernel/security/lockdown` should show
  `[integrity] none`.