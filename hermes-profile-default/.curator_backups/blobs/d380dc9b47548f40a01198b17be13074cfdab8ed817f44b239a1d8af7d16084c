# Honcho deriver gotchas — `.env` pickup and batching (resolved 8/30)

Two non-obvious behaviors that cost a half-hour of false diagnosis on the aios
Honcho bench. See also `references/honcho-self-host-local.md` for the full bring-up.

## `docker compose restart` does NOT pick up `.env` changes
A plain `docker compose restart <svc>` re-runs the container with the env it was
CREATED with — it does NOT re-read `.env`. A container that started before the
`.env` pointed at the right Ollama URL keeps the stale/broken route forever.

Symptom that gives it away: the deriver processes `reconciler:sync_vectors`
(housekeeping that needs no LLM) but silently skips `representation:*` work units.
You see the reconciler rows flip to `processed=t` while representation rows stay
`processed=f`, and no error anywhere.

Fix: **recreate** the container so it rebuilds with the current `.env`:
`docker compose up -d --force-recreate <service>` (or the whole stack).
This one command unblocked the entire bench.

Verification that the running container actually has the right env:
`docker compose exec <svc> sh -c "env | grep -iE 'BASE_URL|LOG_LEVEL'"`.

## The deriver batches representation work — pending is NOT a bug
Representation work units are not claimed until EITHER accumulated tokens reach
`REPRESENTATION_BATCH_WORK_UNIT_TARGET_TOKENS` (default 512) OR the oldest item
exceeds `REPRESENTATION_BATCH_MAX_AGE_SECONDS` (default 1800s = 30 min).
With a few low-token test messages the queue legitimately sits at `pending` for
up to 30 minutes. That is correct batching, not a hang.

Confirm the deriver is actually polling (not wedged) via:
- `docker compose logs deriver` — after the 30-min threshold you see
  `INFO ... age-flushing work unit representation:<ws>:<session>:<peer>`.
- DB: `docker compose exec database psql -U postgres -c "SELECT id, work_unit_key, processed, created_at FROM queue ORDER BY id;"`
  — rows flip to `processed=t` when drained.
- The deriver `PERFORMANCE` line logs `llm_call_duration=XXXXXms` — a non-trivial
  value (e.g. 20s+ on CPU) is proof the local model actually ran, vs. a stub.

## Reading derived output
The representation endpoint is POST with a body, NOT GET:
`POST /v3/workspaces/{ws}/peers/{peer}/representation` body `{"session_id": "..."}`.
Returns the derived text representation (observations about the user).

## Restart vs recreate — general rule for this whole class
When a compose service reads config from `.env` or env_file, assume `restart`
preserves the old environment. If behavior doesn't match a `.env` edit, recreate
before debugging anything else. Applies to any Dockerized service, not just Honcho.
