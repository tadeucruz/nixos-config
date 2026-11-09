# llama-server

`llama-server` comes from `home/programs/llama-cpp.nix`. `LLAMA_ARG_HOST=0.0.0.0`
and `LLAMA_ARG_PORT=9931` are set there, so the port is implicit and peers reach
the server over the tailnet. Always pass `--jinja` for tool calling and
`--alias` so clients (pi/opencode) resolve the model id.

Weights land in `~/.cache/llama.cpp` (`-hf` downloads on first run).

Model facts: 32 layers, only 8 full-attention (4 KV heads, head_dim 256), KV
costs ~32 KB/token — context is cheap, weights are not.

### normandy (MacBook, M4 Pro, 24 GB)

BF16 (18.4 GB) does not fit: no room for macOS plus KV. Use Q8_0 (9.8 GB) or
Q4_K_M (5.8 GB). Raise the Metal wired limit only if Q8 + large context runs out
of memory (resets on reboot).

```bash
# daily driver
llama-server -hf ornith-ai/Ornith-1.5-9B-GGUF:Q4_K_M \
  -c 65536 --jinja -fa on --cache-type-k q8_0 --cache-type-v q8_0 \
  --alias ornith-ai/Ornith-1.5-9B-GGUF:Q4_K_M \
  --temp 0.6 --top-p 0.95 --top-k 20 --presence-penalty 0.0

# higher quality, smaller context
llama-server -hf ornith-ai/Ornith-1.5-9B-GGUF:Q8_0 \
  -c 32768 --jinja -fa on --cache-type-k q8_0 --cache-type-v q8_0 \
  --alias ornith-ai/Ornith-1.5-9B-GGUF:Q8_0 \
  --temp 0.6 --top-p 0.95 --top-k 20 --presence-penalty 0.0

# only if Q8 + 32k still fails
sudo sysctl iogpu.wired_limit_mb=20480
```

### citadel (AMD, ROCm)

```bash
llama-server -hf ornith-ai/Ornith-1.5-9B-GGUF:Q8_0 \
  -c 131072 --jinja -fa on --cache-type-k q8_0 --cache-type-v q8_0 \
  --alias ornith-ai/Ornith-1.5-9B-GGUF:Q8_0 \
  --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0.0 --presence-penalty 1.5
```

### prothean (NVIDIA, CUDA)

```bash
llama-server -hf ornith-ai/Ornith-1.5-9B-GGUF:Q4_K_M \
  -c 65536 --jinja -fa on \
  --alias ornith-ai/Ornith-1.5-9B-GGUF:Q4_K_M \
  --temp 0.6 --top-p 0.95 --top-k 20 --presence-penalty 0.0
```

### Notes

- This build's `--flash-attn` takes a value (`on|off|auto`, default `auto`), so
  `-fa on` — bare `--flash-attn` swallows the next flag.
- Sampling: general tasks `temp=1.0 presence_penalty=1.5`; precise coding
  `temp=0.6 presence_penalty=0`.
- `-c 262144` is the trained maximum, not a practical default: 262144 pushes KV
  to ~8 GB and is only realistic on citadel with quantized cache.
- Vision: add `--mmproj` with `mmproj-Ornith-1.5-9B-BF16.gguf` (~0.9 GB VRAM).
- `--reasoning-format deepseek` puts the `<think|>` trace in
  `message.reasoning_content` (default is `auto`, same effect). Without it the
  tokens land in `content` and pi shows the whole CoT as the answer.
- pi hides thinking behind its own toggle: it sends
  `chat_template_kwargs.enable_thinking`, which the model's template honors, so
  the server flag is only a default.
- `--alias` must equal the `id` in `home/programs/pi/models.json`
  (`ornith-ai/Ornith-1.5-9B-GGUF:<QUANT>`), otherwise pi lists a model the
  server does not advertise.
