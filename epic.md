# EAC Linux v2 readiness

Tracking of [Easy Anti-Cheat Linux v2](https://onlineservices.epicgames.com/news/introducing-easy-anti-cheat-linux-v2)
requirements across hosts.

EAC v2 requires 8 cumulative system features. This file tracks which are
enabled, which are skipped, and why.

> **⚠️ 2026-10-31 — lockdown (#6) rolled back after boot failures.**
> `lockdown=integrity` hung `prothean` and `legion` before journald — see
> "Rollback notes (2026-10-31)".
> Earlier: the 2026-10-16 rollback (Witcher 3 freeze investigation, commit
> `ba69f4b`) was re-enabled on 2026-10-17 with corrected parameters
> (`iommu=on`, not the invalid `amd_iommu=on`; lockdown was not set then
> because the old kernels lacked the option).

## Requirements

| # | Requirement | Status | How / Why |
|---|---|---|---|
| 1 | Signed kernel & modules (well-known key) | ❌ Not enabled | Needs a key from EAC's well-known list (Canonical, Fedora, Debian, openSUSE, Universal Blue, Microsoft UEFI CA, ...). NixOS is not on the list yet. Own keys (lanzaboote / custom MOK) do not count. |
| 2 | TPM 2.0 | ✅ Enabled | `security.tpm2.enable = true` via `modules/security/tpm2.nix` (all Linux hosts). Validated 2026-10-17 with `systemd-cryptenroll --tpm2-device=list` (device listed) and `tpm_version_major = 2`. |
| 3 | Secure Boot | ❌ Not enabled | Deliberately skipped for now. Would also require a well-known key (same blocker as #1). |
| 4 | Measured boot | ⚠️ Partial (verified) | Verified 2026-10-17 on all Linux hosts: firmware event log `/sys/kernel/security/tpm0/binary_bios_measurements` exists, and PCRs 0–7 (plus 9/10/12) are populated. `bootctl status` still reports `Secure Boot: disabled`, `Measured UKI: no`, `Measured OS: no`, so it is not counted as a full requirement. |
| 5 | IOMMU | ✅ Enabled | `iommu=on` via `modules/boot/eac-iommu.nix` (all Linux hosts). The old `amd_iommu=on` was invalid; `iommu=on` is the correct parameter. **citadel/legion:** Jovian's SteamOS cmdline config injected `amd_iommu=off`, which overrides `iommu=on`; `jovian.steamos.useSteamOSConfig` is now `false` in `modules/jovian.nix` (only `earlyoom` is enabled, plus SD automount on legion), so the flag is gone without duplicating Deck-tuned parameters. Validated 2026-10-17 (`/sys/kernel/iommu_groups` non-empty). |
| 6 | Kernel lockdown integrity | ❌ Attempt failed, reverted | Enabled via `lockdown=integrity` (commit `e08a27e`) on citadel/legion/prothean on 2026-10-31 — **prothean and legion failed to boot** (hang before journald) and the change was reverted the same day. Root cause (analysis): nixpkgs unstable signs every module with kmodigest **per-module deterministic certs** (`modules.cer` = 7468 × 260 B), but those certs are only trusted if injected into the kernel image via `linuxPackages.rebuildImage` (`scripts/insert-sys-cert -b vmlinux -c modules.cer` into the `SYSTEM_EXTRA_CERTIFICATE` area). Nothing in nixpkgs or NixOS calls `rebuildImage` automatically — the booted image is the original `…-linux-7.3` build (not `…-linux-image`) without the certs → under `lockdown=integrity` **every** module load is rejected, so the initrd cannot mount root. Verified along the way: gen 35 vs 36 differ **only** in `kernel-params` (kernel/modules/initrd store paths identical); all 7468 modules signed; kernel has `CONFIG_SECURITY_LOCKDOWN_LSM=y`. Re-enabling needs a `rebuildImage` wiring (or a kernel config override with a fixed signing key) — blocked until nixpkgs wires it. See "Rollback notes (2026-10-31)". |
| 7 | Kexec disabled | ✅ Enabled | `boot.kernel.sysctl."kernel.kexec_load_disabled" = 1` in `modules/boot/eac-kexec.nix` (all Linux hosts). Uses the sysctl instead of the `kexec_load_disabled=1` kernel param: applies without reboot and avoids the "unknown parameter" issue. Validated 2026-10-17. |
| 8 | BPF LSM | ✅ Enabled | nixpkgs (unstable and 26.05) sets `security.lsm = [ "landlock" "yama" "bpf" ]`, emitted as `lsm=landlock,yama,bpf`. No repo change needed (`boot.kernelModules = [ "bpf" ]` is unnecessary — BPF LSM is built-in). Validated 2026-10-17: `/sys/kernel/security/lsm` contains `bpf` on all Linux hosts. |

**Score: 4 / 8 enabled** (#2, #5, #7 and #8 active as of 2026-10-17; #4 is active but partial, so not counted). #6 was enabled on 2026-10-31 and **reverted the same day after boot failures** — see "Rollback notes (2026-10-31)".

## Per-host status

| Host | TPM2 | IOMMU/kexec/BPF | Score | Notes |
|---|---|---|---|---|
| `citadel` | ✅ | ✅ | 4/8 | #2 TPM2 ✅, #5 IOMMU ✅, #7 kexec ✅ and #8 BPF LSM ✅; #4 measured boot active but partial (2026-10-17); #6 lockdown attempt rolled back 2026-10-31 (boot failures on prothean/legion — citadel was not rebuilt with it). Repo pins OGC 7.2.14 (pending rebuild). Still suspect for Witcher 3 DX12 freezes. |
| `legion` | ✅ | ✅ | 4/8 | #2 TPM2 ✅, #5 IOMMU ✅, #7 kexec ✅ and #8 BPF LSM ✅; #4 measured boot active but partial (2026-10-17); #6 lockdown attempt caused a boot hang (2026-10-31) and was rolled back. |
| `omega` | ✅ | ✅ | 4/8 | #2 TPM2 ✅, #5 IOMMU ✅, #7 kexec ✅ and #8 BPF LSM ✅; #4 measured boot active but partial (2026-10-17); libvirt passthrough verified; #6 **not possible** on the stock 26.05 kernel (2026-10-31, static analysis of the pinned nixpkgs-stable — no SSH needed). |
| `prothean` | ✅ | ✅ | 4/8 | #2 TPM2 ✅, #5 IOMMU ✅, #7 kexec ✅ and #8 BPF LSM ✅; #4 measured boot active but partial (2026-10-17); #6 lockdown attempt failed to boot (pre-journald hang, 2026-10-31) and was rolled back — running generation 35. |
| `normandy` | N/A | N/A | — | macOS / nix-darwin, out of scope. |

## Rollback notes (2026-10-31)

`lockdown=integrity` (commit `e08a27e`) was reverted after boot failures:

- **prothean**: generation 36 differed from generation 35 **only** in
  `kernel-params` (identical kernel `…-linux-7.3`, modules
  `…-linux-7.3-modules` and initrd store paths). It hung before journald —
  no boot entry between 10:47:16 and 10:51:07. Recovered by booting
  generation 35 from the boot menu.
- **legion**: also hung with the param.
- Evidence gathered on prothean: all 7468 modules in the kernel's module
  tree are signed (`~Module signature appended~`); the kernel has
  `CONFIG_SECURITY_LOCKDOWN_LSM=y`(+`_EARLY`), `CONFIG_MODULE_SIG=y` +
  `MODULE_SIG_ALL=y`, `CONFIG_LOCK_DOWN_KERNEL_FORCE_NONE=y`; and
  `System.map` shows the `system_extra_cert`/`system_extra_cert_used`
  symbols (`CONFIG_SYSTEM_EXTRA_CERTIFICATE=y`,
  `SYSTEM_EXTRA_CERTIFICATE_SIZE = 12000 × 260`).
- Root cause: kmodigest signs each module with a **per-module cert**, and
  the certs only become trusted when injected into the kernel image by
  `linuxPackages.rebuildImage` (`scripts/insert-sys-cert -b vmlinux -c
  modules.cer`). That helper is manual — nothing in nixpkgs or NixOS calls
  it — so the stock boot image contains **no** module-signing key and
  `lockdown=integrity` rejects every module load (initrd cannot mount root).
- Recovery on both hosts: rebuild with this revert and reboot. The failed
  generation (36 on prothean) can be dropped with the usual GC.

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
- **Kernel lockdown (#6):** attempted 2026-10-31 (`lockdown=integrity`,
  commit `e08a27e`) — **boot failure on prothean and legion** (the kmodigest
  module certs are never injected into the booted image;
  `linuxPackages.rebuildImage`/`scripts/insert-sys-cert` is a manual helper
  nothing calls). Reverted the same day. **omega** is additionally blocked on
  nixos-26.05 (stable sets `MODULE_SIG = no` + `SECURITY_LOCKDOWN_LSM = no`);
  note that when omega reaches 26.11 it will hit the same cert-injection
  gap unless nixpkgs wires it.

## Next steps to reach 8/8

1. Investigate the `citadel` Witcher 3 freeze before re-enabling anything.
2. Watch for NixOS joining EAC's well-known key list (or sign with a
   Fedora/Debian key).
3. Enable Secure Boot with that well-known key (likely via shim, not
   lanzaboote — own keys don't count).
4. TPM2/IOMMU/kexec/BPF LSM are done. Lockdown (#6) is **blocked**: the
   kmodigest module certs are not embedded in the stock boot image
   (`linuxPackages.rebuildImage` is manual), so `lockdown=integrity` rejects
   every module. Paths forward: watch for nixpkgs wiring `rebuildImage` into
   `boot.kernelPackages` (this would also unblock omega on 26.11), or
   experiment with wiring `rebuildImage`/`insert-sys-cert` locally.
   - `omega` (nixos-26.05): also blocked by stable's `MODULE_SIG = no` /
     `SECURITY_LOCKDOWN_LSM = no` (until 26.11).
   - `normandy`: N/A (macOS).
5. Re-verify measured boot (#4) once Secure Boot is on.

## Rebuild notes

- `kernelParams` lists are concatenated across modules (base + gaming + host),
  not overwritten.
- After rebuild, check before reboot: `cat /proc/cmdline`.
- Lockdown (#6), if ever re-attempted: the image must carry the kmodigest
  certs (via `linuxPackages.rebuildImage`/`insert-sys-cert`) before
  `lockdown=integrity` is safe to set.
