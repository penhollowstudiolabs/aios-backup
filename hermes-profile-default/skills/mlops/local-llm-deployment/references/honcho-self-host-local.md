# Self-hosting Honcho for Hermes with a local Ollama backend

Captured from the 8/30/2026 Honcho bench on aios (Alyosha). Honcho = plastic-labs
open-source memory library; gives Hermes dialectic user modeling (builds a running
model of the user by reasoning over conversations), unlike flat MEMORY.md.

## Verdict on local reasoning
Honcho's text-generation backend is ANY OpenAI-compatible endpoint — OpenRouter,
Ollama, vLLM, llama.cpp, LiteLLM. So fully-local reasoning is architecturally
supported. The quality bottleneck is the local model: Honcho's value lives in the
background "deriver/dialectic" reasoning, which is exactly where a small CPU model
(3B) is weakest. Decision flow: bench on the existing local model FIRST (prove the
plumbing + see if 3B quality is enough), upgrade the backend to a cheap hosted
model only if too thin. This mirrors the user's evidence-first, cost-conscious
preference.

## Verified working bring-up (Docker Compose on aios)
1. `git clone --depth 1 https://github.com/plastic-labs/honcho.git`
2. `cp docker-compose.yml.example docker-compose.yml`
3. `.env`: route ALL LLM config at local Ollama. On aios use base URL
   `http://172.17.0.1:11434` (see routing pitfall below), no remote API key.
4. Embeddings: `ollama pull nomic-embed-text` (768-dim). Set
   `EMBEDDING_VECTOR_DIMENSIONS` to match (768).
5. `docker compose up -d --build` (long build; run backgrounded).

## Pitfalls (verified)
- **`host.docker.internal` does NOT resolve inside Docker Compose on Linux.**
  Containers reach the host via the compose bridge gateway. Get the actual
  gateway the container sees (`docker compose exec api ip route` — default gw,
  e.g. `172.18.0.1`), NOT the docker0 `172.17.0.1`. A route that times out inside
  a container = wrong gateway.
- **Embedding dim mismatch blocks startup.** Migrations hardcode `Vector(1536)`
  in several files regardless of `.env`. After first up, api container goes
  unhealthy with `public.documents.embedding dim (1536) does not match
  EMBEDDING_VECTOR_DIMENSIONS (768)`. Fix: run the provided script inside the
  api container (it ALTERs the schema):
  `docker compose exec api /app/.venv/bin/python scripts/configure_embeddings.py --yes`
  then `docker compose restart api deriver`.
- **Ollama socket activation overrides `OLLAMA_HOST`.** Setting
  `Environment="OLLAMA_HOST=0.0.0.0:11434"` via a systemd drop-in does NOT take
  effect if Ollama is socket-activated (bound via `172.17.0.1`/`127.0.0.1`). To
  truly rebind you must address the `.socket` unit, not just the `.service`.
- Honcho v3 API root is `/v3/` (workspaces, peers, sessions), NOT `/v1/`.

## Open / unresolved
Container→host Ollama routing was NOT fully resolved at end of session. Options:
bind Ollama to the compose gateway only (tightest, keep off public interfaces) vs
0.0.0.0 (exposes beyond localhost) vs run Ollama as a 5th compose container.
User must choose; confirm what Ollama was originally earmarked for (possibly
Prime/PII lane) before rebinding a working service.
