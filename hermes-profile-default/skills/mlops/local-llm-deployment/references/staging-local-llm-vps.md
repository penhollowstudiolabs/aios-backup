# Staging local-LLM jobs on a shared small CPU VPS (verified incident 8/30/2026)

Cross-cutting operational lesson from the aios Honcho bench, applicable to ANY
local-inference deployment on a small (4-core) CPU-only VPS that already runs a
fleet stack (vault sync, backups, cron, gateway, multiple Hermes profiles).

## The incident
Two local-inference workloads ran concurrently on aios:
- Honcho's in-network Ollama container holding a loaded `qwen2.5:3b` (~254% CPU,
  2.9 GiB resident).
- A separate vault-index rebuild embedding the whole vault through **host**
  Ollama `nomic-embed-text` (~190% CPU).

Result: load average ~9.8 on **4 cores** (~2.3x oversubscribed) → Hostinger
CPU-limit alert ("Your VPS has exceeded its resource limit").

## The rule
**Never run two local-LLM inference jobs concurrently on a shared small CPU VPS.**
Serialize them:
- Memory/cook windows, index rebuilds, and batch embedding jobs each run ALONE.
- A model that is *loaded but idle* still holds RAM and a baseline CPU share — to
  actually free resources, stop the whole container/compose stack (e.g.
  `docker compose down`), not just the client process. Compose volumes survive
  `down`, so this is not data loss.
- Renice heavy one-off batch jobs to lowest priority:
  `renice -n 19 -p <pid>` (and `renice -n 19 -p <child>` if it spawns workers).

## Diagnosing a loaded box without being fooled
- `ps` `%CPU` is a **lifetime average**, not instantaneous — a process can show a
  high `%CPU` while actually sleeping. Confirm load with `uptime` (load average)
  and check instantaneous CPU via a `/proc/<pid>/stat` utime+stime delta sampled
  a few seconds apart (0 delta = idle).
- Don't overreact to a one-shot `%CPU` read; watch `uptime` trend to confirm
  relief is landing.
- `loadavg` lags ~5–15 min: after you stop the offending workload, the 1-min
  figure still shows the spike for a while and drops over several readings. Trust
  the trend, not the first post-stop number.

## CPU caps: lost on recreate, and tight caps cause timeouts (added 8/31)
Two follow-on pitfalls from the same incident that cost real time:

- **`docker update --cpus N` caps are silently dropped by `--force-recreate`.**
  Capping a container (e.g. `docker update --cpus 3 honcho-ollama-1`) protects
  the box, but the cap is **not** persisted across a recreate. If you recreate the
  container later (e.g. to clear a zombie that `docker restart` can't reap), the
  cap is gone and the service runs **uncapped** — a 3B model can then peg 40+ cores
  (`docker stats` showed 4000%+) and re-trigger the exact Hostinger alert. Always
  re-apply the cap after ANY recreate and verify it took:
  `docker inspect <ctr> --format '{{.HostConfig.NanoCpus}}'`.
- **A tight CPU cap causes LLM request timeouts, not just slowness.** Honcho's
  deriver (and similar workers) issue LLM calls with a fixed request timeout. If
  the capped model is too slow to finish within that timeout, the call times out
  and the worker burns retries / backs off, stalling the queue at "in_progress"
  with nothing advancing. A `tenacity.RetryError ... APITimeoutError` in the
  worker log is the signature. Fix is either raise the cap (derivations finish
  before timeout) or raise the worker's request timeout — not "let it keep
  retrying," which crawls.
- A lone busy representation call can hold the single worker while everything else
  queues behind it, freezing the completed count for a long stretch even though the
  model is actively computing. That is "slow due to one long call," not "stuck" —
  check whether instantaneous CPU is high before concluding it's wedged.

## Council/review note
If a design doc claims a workload has "negligible idle" load, scope that claim to
*idle* (model resident, not serving) — a full rebuild/index run through the same
model is a different, much higher number. Validate with real measurements, not
the design assumption.
