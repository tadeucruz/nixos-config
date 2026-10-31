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
| 2 | TPM 2.0 | ✅ Enabled | `security.tpm2.enable = true` via `modules/security/tpm2.nix` (all Linux hosts). Validated 2026-10-17 with `systemd-cryptenroll --tpm2-device=list` (device listed) and `tpm_version_major = 2`. |
| 3 | Secure Boot | ❌ Not enabled | Deliberately skipped for now. Would also require a well-known key (same blocker as #1). |
| 4 | Measured boot | ⚠️ Partial (verified) | Verified 2026-10-17 on all Linux hosts: firmware event log `/sys/kernel/security/tpm0/binary_bios_measurements` exists, and PCRs 0–7 (plus 9/10/12) are populated. `bootctl status` still reports `Secure Boot: disabled`, `Measured UKI: no`, `Measured OS: no`, so it is not counted as a full requirement. |
| 5 | IOMMU | ✅ Enabled | `iommu=on` via `modules/boot/eac-iommu.nix` (all Linux hosts). The old `amd_iommu=on` was invalid; `iommu=on` is the correct parameter. **citadel/legion:** Jovian's SteamOS cmdline config injected `amd_iommu=off`, which overrides `iommu=on`; `jovian.steamos.useSteamOSConfig` is now `false` in `modules/jovian.nix` (only `earlyoom` is enabled, plus SD automount on legion), so the flag is gone without duplicating Deck-tuned parameters. Validated 2026-10-17 (`/sys/kernel/iommu_groups` non-empty). |
| 6 | Kernel lockdown integrity | 🟠 Enabled (pending rebuild) | `lockdown=integrity` via `modules/boot/eac-lockdown.nix`, imported on `citadel` + `legion` + `prothean` (2026-10-31); `omega` excluded (blocked, see below). Available since nixpkgs unstable enabled `CONFIG_SECURITY_LOCKDOWN_LSM` (+ `_EARLY`) + `CONFIG_MODULE_SIG`/`MODULE_SIG_ALL` (deterministic per-module certs via kmodigest) with `CONFIG_LOCK_DOWN_KERNEL_FORCE_NONE=y` — verified at runtime 2026-10-31 on `prothean` (7.3.0: `/sys/kernel/security/lockdown` exists, lockdown in lsm, all modules signed incl. `nvidia`/`acpi_call`) and `citadel` (running OGC 7.2.11 via SSH, repo pins 7.2.14: same config, `modules.cer` + `~Module signature appended~` confirmed). **Omega cannot enable it:** nixpkgs-stable (26.05, rev `6f06d20`) still has `MODULE_SIG = no` + `SECURITY_LOCKDOWN_LSM = no` on every kernel variant (config is per-revision; omega default is 6.18) → lands with nixos-**26.11**. Verify after rebuild: `cat /sys/kernel/security/lockdown` → `none [integrity] confidentiality`. |
| 7 | Kexec disabled | ✅ Enabled | `boot.kernel.sysctl."kernel.kexec_load_disabled" = 1` in `modules/boot/eac-kexec.nix` (all Linux hosts). Uses the sysctl instead of the `kexec_load_disabled=1` kernel param: applies without reboot and avoids the "unknown parameter" issue. Validated 2026-10-17. |
| 8 | BPF LSM | ✅ Enabled | nixpkgs (unstable and 26.05) sets `security.lsm = [ "landlock" "yama" "bpf" ]`, emitted as `lsm=landlock,yama,bpf`. No repo change needed (`boot.kernelModules = [ "bpf" ]` is unnecessary — BPF LSM is built-in). Validated 2026-10-17: `/sys/kernel/security/lsm` contains `bpf` on all Linux hosts. |

**Score: 4 / 8 enabled** (#2, #5, #7 and #8 active as of 2026-10-17; #4 is active but partial, so not counted). **#6 → 🟠 enabled in config 2026-10-31 (pending rebuild): once verified on citadel/legion/prothean the score rises to 5/8**; omega stays at 4/8 until nixos-26.11.

## Per-host status

| Host | TPM2 | IOMMU/kexec/BPF | Score | Notes |
|---|---|---|---|---|
| `citadel` | ✅ | ✅ | 4/8 → 5/8 | #2 TPM2 ✅, #5 IOMMU ✅, #7 kexec ✅ and #8 BPF LSM ✅; #4 measured boot active but partial (2026-10-17); #6 `lockdown=integrity` in config (2026-10-31, pending rebuild — running OGC 7.2.11 already has the config). Note: still under the Witcher 3 freeze investigation (see rollback banner). |
| `legion` | ✅ | ✅ | 4/8 → 5/8 | #2 TPM2 ✅, #5 IOMMU ✅, #7 kexec ✅ and #8 BPF LSM ✅; #4 measured boot active but partial (2026-10-17); #6 `lockdown=integrity` in config (2026-10-31, pending rebuild — same nixpkgs `linux_latest` as prothean, not yet runtime-verified). |
| `omega` | ✅ | ✅ | 4/8 | #2 TPM2 ✅, #5 IOMMU ✅, #7 kexec ✅ and #8 BPF LSM ✅; #4 measured boot active but partial (2026-10-17); libvirt passthrough verified; #6 **not possible** on the stock 26.05 kernel (2026-10-31, static analysis of the pinned nixpkgs-stable — no SSH needed). |
| `prothean` | ✅ | ✅ | 4/8 → 5/8 | #2 TPM2 ✅, #5 IOMMU ✅, #7 kexec ✅ and #8 BPF LSM ✅; #4 measured boot active but partial (2026-10-17); #6 `lockdown=integrity` in config (2026-10-31, pending rebuild — kernel 7.3.0 verified ready: signed NVIDIA + `acpi_call`). |
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
- **Kernel lockdown (#6):** enabled on citadel/legion/prothean (2026-10-31) —
  no custom kernel needed since the nixpkgs unstable kmodigest + lockdown
  config change. **omega excluded**: stable (26.05) still sets
  `MODULE_SIG = no` + `SECURITY_LOCKDOWN_LSM = no`; enable there with
  nixos-26.11 (inherits unstable's config) or override 6.18's config with
  `structuredExtraConfig` (needs a fixed signing key to keep reproducibility).

## Next steps to reach 8/8

1. Investigate the `citadel` Witcher 3 freeze before re-enabling anything.
2. Watch for NixOS joining EAC's well-known key list (or sign with a
   Fedora/Debian key).
3. Enable Secure Boot with that well-known key (likely via shim, not
   lanzaboote — own keys don't count).
4. TPM2/IOMMU/kexec/BPF LSM are done. Lockdown (#6) is enabled on
   citadel/legion/prothean via `modules/boot/eac-lockdown.nix`
   (`lockdown=integrity`) — pending rebuild + boot verification
   (`cat /sys/kernel/security/lockdown` must show `none [integrity] confidentiality`;
   if a module fails to verify, the kernel will refuse to load it — check `dmesg | grep -i signature`).
   - `omega` (nixos-26.05): **blocked** — stable's `common-config.nix` sets
     `MODULE_SIG = no` and `SECURITY_LOCKDOWN_LSM = no`. Options: wait for
     nixos-26.11 (inherits unstable's kmodigest + lockdown), or override the
     6.18 kernel config with `structuredExtraConfig` (needs `MODULE_SIG = yes`
     → reproducibility hit unless a fixed signing key is provided).
   - `normandy`: N/A (macOS).
5. Re-verify measured boot (#4) once Secure Boot is on.

## Rebuild notes

- `kernelParams` lists are concatenated across modules (base + gaming + host),
  not overwritten.
- After rebuild, check before reboot: `cat /proc/cmdline` (should contain
  `lockdown=integrity`).
- After reboot, verify: `cat /sys/kernel/security/lockdown` should show
  `none [integrity] confidentiality` (active mode in brackets).
