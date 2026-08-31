# Honcho local-Ollama routing & deriver — RESOLVED path (8/30/2026)

Supersedes the "Open / unresolved" section of `honcho-self-host-local.md`. The
container→host routing question is settled; read this before re-litigating it.

## The fix that works: run Ollama as a 5th compose container

Container→host Ollama bridging repeatedly fails on Linux Docker Compose
(`host.docker.internal` does not resolve; the host service bound on one bridge
gateway is not reachable from the compose bridge; hairpin routing is unreliable).
The clean, verified fix is to stop bridging entirely and run Ollama **inside the
same compose network**, so Honcho reaches it by service name:

```yaml
  ollama:
    image: ollama/ollama:latest
    restart: unless-stopped
    volumes:
      - ollama-data:/root/.ollama
    # no host ports — internal only, reached as http://ollama:11434
```

Then:
- `docker compose up -d ollama`
- `docker compose exec ollama ollama pull qwen2.5:3b`
- `docker compose exec ollama ollama pull nomic-embed-text`
- Point every `.env` LLM/embedding override at `http://ollama:11434/v1`.
- Verify container→container reachability from the api container:
  `docker compose exec api python -c "import urllib.request; print(urllib.request.urlopen('http://ollama:11434/api/version', timeout=8).read())"`.

This leaves the host Ollama untouched — important when it may be earmarked for
another lane (e.g. Prime/PII). Avi chose this option explicitly over rebinding.

## CRITICAL: `restart` does not pick up `.env` — use `--force-recreate`

If the deriver container was created BEFORE the `.env` model config existed, a
plain `docker compose restart deriver` reuses the stale env and the deriver stays
stuck: the queue fills and no `representation:` work is ever claimed, even though
the model is reachable. You MUST:

```
docker compose up -d --force-recreate deriver
```

Verify: `docker compose exec deriver env | grep BASE_URL` must show
`http://ollama:11434/v1`, not a stale host-gateway URL.

Telling symptom: the reconciler's `sync_vectors` still runs every 5 min (so the
polling loop is alive) but `representation:` work units never drain and
`summary`/`peer_representation` stay null.

## Deriver batching is by design, not a bug

Representation work is only claimed once either accumulated tokens reach
`REPRESENTATION_BATCH_WORK_UNIT_TARGET_TOKENS` (default 512) OR the oldest pending
item exceeds `REPRESENTATION_BATCH_MAX_AGE_SECONDS` (default 1800 = 30 min). A
handful of short test messages (tens of tokens) sitting "pending" is expected —
it drains on the 30-min age-flush. Watch the deriver log for
`age-flushing work unit representation:...` then `llm_call_duration=NNNNms` (the
local CPU model working) and `observation_count=N` — that proves the model ran.

## Hermes integration (verify, don't hand-edit)

- `hermes config set memory.provider honcho` — the CLI; direct writes to
  `config.yaml` are refused as security-sensitive.
- Config at `~/.hermes/honcho.json`: hosts block with `base_url` = local server,
  no auth for the bench.
- `hermes memory status` → provider honcho, `available ✓`.
- Server health: `curl http://localhost:8000/health` → `{"status":"ok"}`.
