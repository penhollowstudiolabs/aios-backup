# Local LLM as a Docker compose container (validated 2026-08-30)

When a containerized app (e.g. Honcho) needs a local LLM that runs on the host,
**container→host routing is the fragile part**. Three things fail before the model
itself is ever the problem:

1. `host.docker.internal` does **not** resolve inside Docker Compose on Linux.
2. Rebinding the host model via a systemd drop-in (e.g. `OLLAMA_HOST=0.0.0.0`)
   can be **silently overridden by socket activation** — you must edit the
   `.socket` unit, not just the `.service`.
3. Pointing at a guessed bridge IP (docker0 `172.17.0.1` vs the compose gateway
   `172.18.0.1`) times out unless you use the gateway the container actually sees
   (`docker compose exec api ip route`).

## The validated fix: run the model as a compose container

Share the app's network — no host routing at all. Worked end-to-end on aios.

```yaml
services:
  ollama:
    image: ollama/ollama:latest
    restart: unless-stopped
    volumes:
      - ollama-data:/root/.ollama
    # no host port — internal only, reached as http://ollama:11434

volumes:
  ollama-data:
```

Then:
```bash
docker compose up -d ollama
docker compose exec ollama ollama pull qwen2.5:3b
docker compose exec ollama ollama pull nomic-embed-text
```
Point the app's `.env` LLM/embedding base URLs at `http://ollama:11434`
(not `host.docker.internal`, not a `172.x`).

Verify container→container:
```bash
docker compose exec api <python> -c \
  "import urllib.request; print(urllib.request.urlopen('http://ollama:11434/api/version', timeout=8).read().decode())"
```
And an actual completion the way the app would:
```bash
# POST /api/chat to http://ollama:11434 from the api container
```

## Why this is the right default

- No hairpin routing, no socket-activation surprises.
- Self-contained and reversible.
- **Leaves a host Ollama earmarked for another lane completely untouched**
  (e.g. Prime / PII-lane on aios). During debugging, revert any host-Ollama
  systemd drop-in you created so the host service returns to its original state.

## Related pitfall — embedding dim mismatch

Honcho migrations hardcode `Vector(1536)` regardless of `.env`; a 768-dim local
embedding model (nomic-embed-text) then fails startup validation. Fix with the
provided script (ALTERs the schema), then restart:
```bash
docker compose exec api /app/.venv/bin/python scripts/configure_embeddings.py --yes
docker compose restart api deriver
```
