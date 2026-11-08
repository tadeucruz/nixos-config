# EAC Linux v2 readiness

Tracking of [Easy Anti-Cheat Linux v2](https://onlineservices.epicgames.com/news/introducing-easy-anti-cheat-linux-v2)
requirements across hosts.

EAC v2 requires 8 cumulative system features. This file tracks which are
enabled, which are skipped, and why.

> **⚠️ 2026-11-08 — lockdown (#6) retry also failed.**
> A kernel image rebuilt with the kmodigest certificates embedded
> (`linuxPackages.rebuildImage`) was built for `legion` and verified offline
> (1,940,120 B ≈ 7,473 certs, `system_certificate_list_size` patched,
> `module_cert_size = 0`), but booting it with `lockdown=integrity` **still
> hangs before journald**. The experiment was removed again; #6 is not usable
> out of the box — see "Rollback notes (2026-11-08)".
>
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
| 6 | Kernel lockdown integrity | ❌ Not usable out of the box | Two attempts, both hang before journald. **2026-10-31:** `lockdown=integrity` (commit `e08a27e`) on citadel/legion/prothean with the stock image — all modules rejected (kmodigest certs not embedded). **2026-11-08:** on `legion`, image rebuilt with `linuxPackages.rebuildImage` so `scripts/insert-sys-cert` embeds the certs. Verified offline on the built bzImage: `system_extra_cert_used = 1,940,120 B` (≈7,473 certs), `system_certificate_list_size` patched to match, `module_cert_size = 0` — so the certs are present and loaded into `.builtin_trusted_keys`. Still hangs before journald with `lockdown=integrity`. Verbose boot entries (plymouth off, `ignore_loglevel`, `loglevel=7`, `systemd.log_level=debug`) were prepared but the attempt was abandoned as not ready. **Do not retry locally**; wait for the upstream work in [#549372](https://github.com/NixOS/nixpkgs/issues/549372) (autopen + hash-based module integrity). |
| 7 | Kexec disabled | ✅ Enabled | `boot.kernel.sysctl."kernel.kexec_load_disabled" = 1` in `modules/boot/eac-kexec.nix` (all Linux hosts). Uses the sysctl instead of the `kexec_load_disabled=1` kernel param: applies without reboot and avoids the "unknown parameter" issue. Validated 2026-10-17. |
| 8 | BPF LSM | ✅ Enabled | nixpkgs (unstable and 26.05) sets `security.lsm = [ "landlock" "yama" "bpf" ]`, emitted as `lsm=landlock,yama,bpf`. No repo change needed (`boot.kernelModules = [ "bpf" ]` is unnecessary — BPF LSM is built-in). Validated 2026-10-17: `/sys/kernel/security/lsm` contains `bpf` on all Linux hosts. |

**Score: 4 / 8 enabled** (#2, #5, #7 and #8 active as of 2026-10-17; #4 is active but partial, so not counted). #6 was enabled on 2026-10-31 and reverted the same day; a second attempt with a certificate-embedded image on 2026-11-08 (see below) also hung and was removed — it is not counted.

## Per-host status

| Host | TPM2 | IOMMU/kexec/BPF | Score | Notes |
|---|---|---|---|---|
| `citadel` | ✅ | ✅ | 4/8 | #2 TPM2 ✅, #5 IOMMU ✅, #7 kexec ✅ and #8 BPF LSM ✅; #4 measured boot active but partial (2026-10-17); #6 lockdown attempt rolled back 2026-10-31 (boot failures on prothean/legion — citadel was not rebuilt with it). Repo pins OGC 7.2.14 (pending rebuild). Still suspect for Witcher 3 DX12 freezes. |
| `legion` | ✅ | ✅ | 4/8 | #2 TPM2 ✅, #5 IOMMU ✅, #7 kexec ✅ and #8 BPF LSM ✅; #4 measured boot active but partial (2026-10-17); #6 attempts on 2026-10-31 (stock image) and 2026-11-08 (certificate-embedded image) both hung before journald and were removed. |
| `omega` | ✅ | ✅ | 4/8 | #2 TPM2 ✅, #5 IOMMU ✅, #7 kexec ✅ and #8 BPF LSM ✅; #4 measured boot active but partial (2026-10-17); libvirt passthrough verified; #6 **not possible** on the stock 26.05 kernel (2026-10-31, static analysis of the pinned nixpkgs-stable — no SSH needed). |
| `prothean` | ✅ | ✅ | 4/8 | #2 TPM2 ✅, #5 IOMMU ✅, #7 kexec ✅ and #8 BPF LSM ✅; #4 measured boot active but partial (2026-10-17); #6 lockdown attempt failed to boot (pre-journald hang, 2026-10-31) and was rolled back — running generation 35. |
| `normandy` | N/A | N/A | — | macOS / nix-darwin, out of scope. |

## Rollback notes (2026-11-08)

Second attempt at #6, on `legion` only, this time with the certificates
embedded in the boot image. Everything was removed again after the boot still
hung.

- Wiring: `linuxPackages.rebuildImage { target; modulesTree; }` (nixpkgs'
  `scripts/insert-sys-cert` step), with `$out/kernel` pointed at its `bzImage`,
  plus `lockdown=integrity`. Exposed as a `specialisation` so the default
  generation stayed bootable.
- Image verified **offline** before booting, by extracting `vmlinux` from the
  built `bzImage` (`scripts/extract-vmlinux`) and reading the symbols from
  `System.map`:
  - `system_extra_cert_used = 1,940,120 B` (7,473 DER certs)
  - `system_certificate_list_size = 1,940,120` (patched by `insert-sys-cert`)
  - `module_cert_size = 0`
  - image grew 14,627,328 → 15,315,456 B (consistent with ~0.4× compressed
    certs), so the certs really are in the booted image.
- Result: selecting the `eac-lockdown` entry still **hangs before journald**
  (no boot record; recovered by booting the normal entry). This is therefore
  not a missing-certificate problem. Verbose diagnostic entries (plymouth off,
  `ignore_loglevel`, `loglevel=7`, `systemd.log_level=debug`) were prepared but
  the experiment was abandoned before capturing a console log, so the actual
  reason remains unknown.
- Reverted: `modules/boot/eac-image.nix`, `modules/boot/eac-lockdown.nix` and
  the legion `specialisation`s were deleted. No host carries the parameter.
- Conclusion: #6 is not reachable out of the box on this nixpkgs pin. Wait for
  the upstream work in
  [#549372](https://github.com/NixOS/nixpkgs/issues/549372) (autopen wiring and
  hash-based module integrity) instead of retrying locally.

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
- **Kernel lockdown (#6):** two attempts — 2026-10-31 with the stock image
  (`lockdown=integrity`, commit `e08a27e`) and 2026-11-08 on `legion` with a
  `rebuildImage` image whose certificates were verified offline. Both **hang
  before journald**; all changes were reverted. Not usable out of the box on
  this nixpkgs pin. **omega** is additionally blocked on nixos-26.05 (stable
  sets `MODULE_SIG = no` + `SECURITY_LOCKDOWN_LSM = no`).

## Next steps to reach 8/8

1. Investigate the `citadel` Witcher 3 freeze before re-enabling anything.
2. Watch for NixOS joining EAC's well-known key list (or sign with a
   Fedora/Debian key).
3. Enable Secure Boot with that well-known key (likely via shim, not
   lanzaboote — own keys don't count).
4. TPM2/IOMMU/kexec/BPF LSM are done. Lockdown (#6) is **not reachable
   locally**: even with the kmodigest certificates embedded via
   `linuxPackages.rebuildImage` (verified in the image), booting with
   `lockdown=integrity` still hangs before journald on `legion` (2026-11-08).
   **Do not retry** until the upstream work lands:
   [#549372](https://github.com/NixOS/nixpkgs/issues/549372) — autopen wiring
   plus hash-based module integrity (single Merkle root instead of thousands of
   per-module certs).
   - `omega` (nixos-26.05): also blocked by stable's `MODULE_SIG = no` /
     `SECURITY_LOCKDOWN_LSM = no` (until 26.11).
   - `normandy`: N/A (macOS).
5. Re-verify measured boot (#4) once Secure Boot is on.

## References

- [NixOS/nixpkgs#549372 — Tracking: End-to-end NixOS boot security](https://github.com/NixOS/nixpkgs/issues/549372)
  — upstream work (autopen, NixOS signing keys, shim review, measured boot,
  lockdown) that unblocks #1, #3 and #6. Track it instead of watching for a
  key list update; do not contact Epic individually (see the Discourse thread).
  - Discourse: [EAC Linux v2 requirements vs boot security work](https://discourse.nixos.org/t/eac-linux-v2-requirements-vs-boot-security-work-in-549372/80560)

## Rebuild notes

- `kernelParams` lists are concatenated across modules (base + gaming + host),
  not overwritten.
- After rebuild, check before reboot: `cat /proc/cmdline`.
- Lockdown (#6): do not re-attempt locally. Embedding the kmodigest certs via
  `linuxPackages.rebuildImage`/`insert-sys-cert` is not enough — the resulting
  image (certs verified present) still hangs before journald. Wait for
  [#549372](https://github.com/NixOS/nixpkgs/issues/549372).
