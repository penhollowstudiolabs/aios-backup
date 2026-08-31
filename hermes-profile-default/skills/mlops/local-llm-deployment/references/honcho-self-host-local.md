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
  `Environment=\"OLLAMA_HOST=0.0.0.0:11434\"` via a systemd drop-in does NOT take
  effect if Ollama is socket-activated (bound via `172.17.0.1`/`127.0.0.1`). To
  truly rebind you must address the `.socket` unit, not just the `.service`.
- Honcho v3 API root is `/v3/` (workspaces, peers, sessions), NOT `/v1/`.
- **A plain `docker compose restart` may not pick up `.env` model routing.**
  If the deriver was started before the `.env` pointed at a reachable Ollama, a
  restart keeps the old config; use `--force-recreate` so the container rebuilds
  with current env. (Signature: reconciler `sync_vectors` runs fine — it needs no
  LLM — but `representation` work never gets claimed.)
- **Representation derivation is batched.** The deriver won't claim a
  representation work unit until either accumulated tokens reach the target
  (default 512) OR the oldest pending item passes `REPRESENTATION_BATCH_MAX_AGE_SECONDS`
  (default 1800s). Small test messages (tens of tokens) sit "pending" until the
  age-flush fires — that's by design, not a stuck queue. Check
  `docker logs deriver` for an `age-flushing work unit` INFO line.

## RESOLVED 8/30: container→host Ollama routing
The working fix is **run Ollama as a 5th compose container on the same network**,
reached as `http://ollama:11434` — containers then talk to it directly, no
container→host hairpin routing at all. This is the user's chosen Option 1. Steps:
- Add to docker-compose.yml:
  ```yaml
  ollama:
    image: ollama/ollama:latest
    restart: unless-stopped
    volumes:
      - ollama-data:/root/.ollama
  ```
  (no host ports; internal to the compose network) + declare `ollama-data:` under
  `volumes:`.
- Pull models inside the container: `docker compose exec ollama ollama pull qwen2.5:3b`
  and `... pull nomic-embed-text`.
- Point `.env` endpoints at `http://ollama:11434` (all 10 LLM+embedding configs).
- Recreate the other containers with `--force-recreate` so they pick up the new env.
- Verify reachability from the api container:
  `docker compose exec api python -c "import urllib.request; print(urllib.request.urlopen('http://ollama:11434/api/version', timeout=8).read())"`
- This leaves the host Ollama (Prime/PII lane, 127.0.0.1:11434) completely
  untouched — do NOT collapse it with the in-container one (Ollama hard rule).
