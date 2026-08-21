# Prime Agent lab sandbox on aios (setup 8/13)

Context: Avi wants to **study** Prime Agent (Prime Intellect, MIT, open-source coding
agent, v0.7.2, #1 on GitHub) as a disposable, sandboxed harness on aios. It is a
**lab for studying the design, NOT a workhorse** — Alyosha and Hollow remain the
real agent pair. Avi intends to "steal the four design patterns" for our own stack.

## The four design patterns Avi wants to study (video + repo, verified)
1. **One-tool surface** — model faces a single persistent IPython kernel instead of a
   10–20 tool toolbox. State survives turns AND compaction; new capability = new
   Python package, so the model's decision-space stays flat.
2. **Fire-and-forget delegation** — `handle = await rlm("subtask")` returns a child
   handle immediately and never returns the answer; results arrive later via
   `agent_message` replies or files.
3. **Immutable-base + learning-layer** — `/refine` writes lessons to a supplemental
   layer ABOVE an immutable base system prompt, with before/after snapshots for
   rollback. Learning can edit notes; it cannot ship itself new code.
4. **Autonomy = budgets + gates** — bounded turn/token/time budgets + user quality
   gates. Their most honest line: *"reaching a limit does not imply task success."*

Applicable yardsticks for ANY self-improving agent (incl. Hermes): What can it not
edit? Can you roll it back? Can you read what it learned?

## Live state on aios
- Image `prime-agent-lab`, container `prime-lab` (running, `--restart unless-stopped`).
- State in named volume `prime-lab-state` mounted at `/home/prime/.prime` (sessions survive).
- Host wrapper `/usr/local/bin/prime-lab` (TTY-aware).
- Telemetry disabled via `/home/prime/.prime/agent/settings.json` → `{"telemetry":{"enabled":false}}`.
- **Not authenticated** — pending Avi's choice: `/login` (Claude sub, billed from
  Claude's *extra usage* pool not plan limits) OR OpenRouter/DeepSeek API key (same
  billing lane as fallback) OR leave unauthenticated to study harness only.

## Reproducible Dockerfile (the recipe)
```dockerfile
FROM node:22-bookworm-slim            # Prime Agent needs Node >= 22.8
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates git \
    && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash prime     # non-root agent user
# Install as ROOT: the installer does `npm install -g` which can't write /usr/local as non-root
RUN curl -fsSL https://app.primeintellect.ai/prime-agent/install.sh | sh \
    && prime-agent --version
RUN mkdir -p /work && chown prime:prime /work
WORKDIR /work
USER prime
ENTRYPOINT ["/usr/local/bin/prime-agent"]
```

Container bring-up (4 pitfalls in the exact order they bite):
```bash
# (1) chown the volume as ROOT first — default container USER is prime, so a plain
#     `--entrypoint chown` runs as prime and fails EACCES:
docker run --rm -u root -v prime-lab-state:/data --entrypoint chown prime-agent-lab -R prime:prime /data
# (2) the image ENTRYPOINT (prime-agent) overrides any `docker run ... sleep infinity`,
#     so override it explicitly or the container immediately exits:
docker run -d --name prime-lab --restart unless-stopped --entrypoint sleep \
  -v prime-lab-state:/home/prime/.prime -w /work prime-agent-lab infinity
```

Host wrapper `/usr/local/bin/prime-lab`:
```bash
#!/bin/bash
set -e
if ! docker ps --format '{{.Names}}' | grep -q '^prime-lab$'; then
  echo "Starting prime-lab container..."; docker start prime-lab >/dev/null; sleep 1
fi
TTY_FLAG=""
if [ -t 0 ] && [ -t 1 ]; then TTY_FLAG="-it"; fi
docker exec $TTY_FLAG -w /work prime-lab /usr/local/bin/prime-agent "$@"
```

## Pitfalls (in the order they bit, 8/13)
1. **`npm install -g` EACCES as non-root** — the installer does a global npm install
   into `/usr/local`, which a non-root user can't write. Fix: install as root, run
   the agent as the unprivileged `prime` user.
2. **Image `ENTRYPOINT` overrides your `docker run` command** — passing
   `prime-agent-lab sleep infinity` still runs `prime-agent` (the ENTRYPOINT), which
   tries to open a session and exits. Fix: `--entrypoint sleep ... infinity`.
3. **Named volume is root-owned** → agent dies with `EACCES mkdir
   /home/prime/.prime/agent/sessions`. Fix: chown the volume as root first
   (`-u root --entrypoint chown`), NOT as the default `prime` user.
4. **`docker exec -it` breaks non-interactive calls** — "cannot attach stdin to a
   TTY-enabled container because stdin is not a terminal". Fix: TTY-detect in the
   wrapper (only `-it` when both stdin and stdout are TTYs).
5. **Telemetry is ON by default** (pseudonymous usage metrics; no prompts/responses/
   file paths per their notice). Disable in settings.json before letting it run.

## Security posture
Prime Agent is explicitly **NOT a security sandbox** — it executes model-generated
Python with the worker's OS permissions. The container IS the boundary (non-root
user, work confined to `/work`, state in the volume). Do not point it at untrusted
repos on the host.

## Quick commands
- `prime-lab` — interactive TUI in `/work`; `prime-lab bash` — shell in container
- `prime-lab --version` / `prime-lab -p "prompt"` — one-shots
- `docker exec prime-lab ls -ld /home/prime/.prime /work` — verify writability
