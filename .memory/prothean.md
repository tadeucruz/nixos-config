# Prothean

- DELL laptop (iGPU amdgpu + dGPU NVIDIA, Prime offload), CUDA, perfil de jogo.
- SSH: `ssh prothean` (usuário `tadeucruz`).

## Energia (2026-11-08)

- Sintoma: suspendia por ociosidade mesmo com ajuste de tampa; dormiu 22h16 (07/11 15:34 → 08/11 13:50).
- Causa: `powerdevilrc` sem `AutoSuspendAction` nos perfis → default do Plasma suspende por idle; ajuste antigo (`stay-awake-ac.nix`) só cobria tampa no AC.
- Correção: `hosts/prothean/stay-awake.nix` — logind ignora tampa (todas as fontes) e `IdleAction`; PowerDevil (AC/battery/lowBattery) com `autoSuspend.action = "nothing"` e tampa só desligando a tela.
- Commit: `9dadb07` (`make check` OK). Ação crítica de bateria permanece no default (proteção de dados).
