# Prothean

- DELL laptop (iGPU amdgpu + dGPU NVIDIA, Prime offload), CUDA, gaming profile.
- SSH: `ssh prothean` (user `tadeucruz`).

## Power (2026-11-08)

- Symptom: suspended on idle even with lid settings; slept from 22h16 (07/11 15:34 → 08/11 13:50).
- Cause: `powerdevilrc` missing `AutoSuspendAction` in profiles → Plasma default suspends on idle; old fix (`stay-awake-ac.nix`) only covered lid on AC.
- Fix: `hosts/prothean/stay-awake.nix` — logind ignores lid (all sources) and `IdleAction`; PowerDevil (AC/battery/lowBattery) with `autoSuspend.action = "nothing"` and lid only turns off screen.
- Commit: `9dadb07` (`make check` OK). Critical battery action stays at default (data protection).
