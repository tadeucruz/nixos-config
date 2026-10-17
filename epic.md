# EAC Linux v2 readiness

Tracking of [Easy Anti-Cheat Linux v2](https://onlineservices.epicgames.com/news/introducing-easy-anti-cheat-linux-v2)
requirements across hosts.

EAC v2 requires 8 cumulative system features. This file tracks which are
enabled, which are skipped, and why.

> **⚠️ 2026-10-16 — rolled back for investigation.**
> The prerequisite changes from commit `ba69f4b` were reverted on all hosts to
> rule them out as the cause of intermittent freezes in *The Witcher 3* (DX12)
> on `citadel`. Re-enable after the freeze is investigated.
> Note: on `citadel` the kernel rejected both `amd_iommu=on`
> (`AMD-Vi: Unknown option - 'on'`) and `lockdown=integrity`
> (`Unknown kernel command line parameters`) — so #5 and #6 were never actually
> active even before the rollback. See "Rollback notes" below.

## Requirements

| # | Requirement | Status | How / Why |
|---|---|---|---|
| 1 | Signed kernel & modules (well-known key) | ❌ Not enabled | Needs a key from EAC's well-known list (Canonical, Fedora, Debian, openSUSE, Universal Blue, Microsoft UEFI CA, ...). NixOS is not on the list yet. Own keys (lanzaboote / custom MOK) do not count. |
| 2 | TPM 2.0 | ⏸️ Rolled back | Was `security.tpm2.enable = true` via `modules/desktop/tpm2.nix` (now removed). Hardware has TPM 2.0 (`/dev/tpm0` present). |
| 3 | Secure Boot | ❌ Not enabled | Deliberately skipped for now. Would also require a well-known key (same blocker as #1). |
| 4 | Measured boot | ⚠️ Partial | systemd-boot measures into TPM PCRs by default, but without Secure Boot (#3) EAC may not accept the attestation. |
| 5 | IOMMU | ⏸️ Rolled back | Was `amd_iommu=on` in `modules/boot/base.nix`. Kernel rejects `on` as an unknown option; the pre-existing `amd_iommu=off` was what actually applied. |
| 6 | Kernel lockdown integrity | ⏸️ Rolled back | Was `lockdown=integrity` in `modules/boot/base.nix`. The OGC kernel did not recognize the parameter and `/sys/kernel/security/lockdown` never existed → never active. |
| 7 | Kexec disabled | ⏸️ Rolled back | Was `kexec_load_disabled=1` in `modules/boot/base.nix`. |
| 8 | BPF LSM | ⏸️ Rolled back | Was `lsm=...,bpf` + `boot.kernelModules = [ "bpf" ]` in `modules/boot/base.nix`. |

**Score: 0 / 8 enabled** (all prerequisite changes rolled back on 2026-10-16).

## Per-host status

| Host | TPM2 | IOMMU/lockdown/kexec/BPF | Score | Notes |
|---|---|---|---|---|
| `citadel` | ⏸️ | ⏸️ | 0/8 | Rolled back — suspect for Witcher 3 DX12 freezes. |
| `legion` | ⏸️ | ⏸️ | 0/8 | Rolled back. |
| `omega` | ⏸️ | ⏸️ | 0/8 | Rolled back. |
| `prothean` | ⏳ Pending | ⏳ Pending | — | Deferred: NVIDIA out-of-tree driver + `acpi_call` + AWCC conflict with `lockdown=integrity`. Needs physical access to test. |
| `normandy` | N/A | N/A | — | macOS / nix-darwin, out of scope. |

## Rollback notes (2026-10-16)

Reverted commit `ba69f4b` on all hosts, keeping this file for tracking.

- On `citadel`, the kernel command line showed `AMD-Vi: Unknown option - 'on'`
  and listed `lockdown=integrity` under "Unknown kernel command line
  parameters". So neither IOMMU (#5) nor lockdown (#6) was in effect — the OGC
  kernel does not support those options as written. `/sys/kernel/security/lockdown`
  was absent.
- The freeze signature on `citadel` (Witcher 3 DX12) — `RenderThread` pegged at
  ~100% CPU with the GPU idle, no amdgpu ring timeout, `vkd3d_fence`/`vkd3d_queue`
  threads idle — matches the known upstream vkd3d-proton issues
  [#2880](https://github.com/HansKristian-Work/vkd3d-proton/issues/2880) and
  [#1638](https://github.com/HansKristian-Work/vkd3d-proton/issues/1638), not a
  kernel security feature. This rollback is to isolate/confirm that.
- If the freezes persist after this revert, the cause is elsewhere (Proton/
  vkd3d layer). Workarounds to try: `VKD3D_DISABLE_EXTENSIONS=VK_KHR_present_wait`,
  DirectX 11 mode, or a different Proton build.

## What is intentionally NOT enabled

- **Secure Boot (#3):** skipped by decision. Even if enabled, own keys are
  rejected — EAC requires a well-known key in the UEFI db / MOK.
- **Well-known signed kernel (#1):** blocked until either NixOS is added to
  EAC's well-known list (contact: `linux-gaming@epicgames.com`) or the kernel
  is signed with a key from a distro already on the list (Fedora/Debian/etc).
- **prothean lockdown/IOMMU/TPM2:** postponed — lockdown breaks NVIDIA MSR
  writes and `acpi_call`; needs hands-on testing.

## Next steps to reach 8/8

1. Investigate the `citadel` Witcher 3 freeze before re-enabling anything.
2. Watch for NixOS joining EAC's well-known key list (or sign with a
   Fedora/Debian key).
3. Enable Secure Boot with that well-known key (likely via shim, not
   lanzaboote — own keys don't count).
4. Re-enable TPM2/IOMMU/lockdown/kexec/BPF LSM on the hosts (note: `amd_iommu=on`
   and `lockdown=integrity` are ignored by the OGC kernel — use valid options
   and verify `cat /sys/kernel/security/lockdown`).
5. Re-verify measured boot (#4) once Secure Boot is on.

## Rebuild notes

- `kernelParams` lists are concatenated across modules (base + gaming + host),
  not overwritten.
- After rebuild, check before reboot: `cat /proc/cmdline`.
- After reboot, verify: `cat /sys/kernel/security/lockdown` should show
  `[integrity] none`.
