# Honcho memory backend on a local (CPU) LLM — bench notes

Context: 2026-08-30 bench on VPS2 `aios` (headless, 4-core, 16 GiB RAM, **no GPU**,
Ollama already running `qwen2.5:3b`). Honcho = plastic-labs, AGPL-3.0, open-source
memory library that builds a running model of a user by reasoning over conversations
post-hoc (user modeling / dialectic), vs. Hermes's flat MEMORY.md/USER.md.
Hermes has first-class support: `hermes memory setup` → select `honcho`.

> **Status (updated 8/31):** the bench was brought up, verified end-to-end (server
> health `{"status":"ok"}`, local qwen2.5:3b derived a real user representation from
> test messages), and then **stopped by Avi as a conscious decision** — a 3B model on
> a 4-core VPS proved too resource-heavy for single-session modeling value. The bring-up
> config below is verified-working; the *conclusion* was "not worth a 5-day cook on this
> box," not "it didn't work." Data/volumes were preserved on stop.

## Why this class matters (the problem it solves)
Flat memory (MEMORY.md / Holographic token-bound regex) fails on **paraphrase
resurfacing** — a captured intent and a later query that share little wording won't
be recalled. Honcho's dialectic/semantic modeling is the learned-semantic layer
Holographic isn't. Relevant to any "things captured never resurface" failure.

## Sizing decision (the real judgment)
- Honcho's *value* = the background reasoning (Deriver/Dialectic/Dream) that extracts
  preferences/style/goals. That is exactly where a small CPU model is weakest.
- Community reference recommends **Llama 3.3 70B (~40GB VRAM)** for the workers — not
  feasible on a CPU-only VPS. `glm-4.7-flash` class (~4-8B) is the pragmatic CPU tier.
- **Bench before spend:** run on the existing local 3B first to prove plumbing and see
  if quality suffices; upgrade the backend to a small hosted/OpenRouter model ONLY if
  the bench shows it's too thin (bounded cost, mirrors cost-conscious default).
- Embeddings can stay fully local and cheap (`nomic-embed-text`, 768-dim).

## Serving stack (CPU VPS) — RESOLVED routing
- Honcho server itself: `git clone --depth 1 https://github.com/plastic-labs/honcho`
  → `cp docker-compose.yml.example docker-compose.yml` → `docker compose up -d --build`.
  Needs Docker; image builds from source (several minutes). Containers: api, deriver,
  database (pgvector/pgvector:pg15), redis. All ports bind to 127.0.0.1.
- **`host.docker.internal` does NOT resolve inside Docker Compose on Linux — do not
  route Ollama through it.** The verified fix is to run Ollama as a **5th compose
  container** on the same network, reached as `http://ollama:11434` (see
  `references/honcho-routing-resolved.md` and `references/honcho-self-host-local.md`).
- Ollama needs a non-empty `api_key` even for local; any placeholder works.

## .env routing (all text-gen + embedding workers → local Ollama)
Key vars (from `honcho/.env.template`). The template defaults everything to
`openai/gpt-5.4-mini`; override per-module with `__MODEL_CONFIG__OVERRIDES__BASE_URL`
and `__API_KEY_ENV`:
- `LLM_OPENAI_API_KEY=ollama` (placeholder, required)
- Embeddings: `EMBEDDING_MODEL_CONFIG__MODEL=nomic-embed-text`,
  `EMBEDDING_VECTOR_DIMENSIONS=768`, `__BASE_URL=http://ollama:11434/v1`
- Deriver: `DERIVER_MODEL_CONFIG__MODEL=qwen2.5:3b` + BASE_URL override
- Dialectic: `DIALECTIC_LEVELS__<level>__MODEL_CONFIG__MODEL=qwen2.5:3b` + BASE_URL
  (set for minimal/low/medium/high/max levels)
- Summary: `SUMMARY_MODEL_CONFIG__MODEL=qwen2.5:3b` + BASE_URL
- Dream: `DREAM_DEDUCTION_MODEL_CONFIG__MODEL` / `DREAM_INDUCTION_MODEL_CONFIG__MODEL`
  + BASE_URL
- Keep `AUTH_USE_AUTH=false`, `VECTOR_STORE_TYPE=pgvector`, telemetry/metrics off
  for a bench.
- **Models must support tool calling (function calling)** — a real constraint; verify
  the chosen local model supports it before assuming it works.
- After editing `.env`, **recreate** the deriver/api containers with `--force-recreate`
  (a plain `restart` does NOT re-read `.env`). See `honcho-deriver-pitfalls.md`.

## Boundaries that kept the bench safe
- Contained to the bench profile only — no other agent's profile/memory touched.
- No remote/hosted reasoning spend during the bench; embeddings local/free.
- No vault, routing, or live-business changes.
- Review after a fixed cook interval, comparing the derived user-model against
  ground truth before any decision to keep/upgrade/abandon.
