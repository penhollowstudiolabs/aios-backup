# Prime Agent Lab — exact recipe (v0.7.2, stood up 2026-08-13)

Prime Agent (PrimeIntellect-ai/prime-agent, MIT) is a self-improving RLM coding
agent, #1 on GitHub (~15k stars). It is a fork of `pi` (badlogic/earendil-works).
Free harness; model is a swappable parameter via subscription or API key.

## Design in one sentence

The model gets **one tool — a persistent IPython kernel.** Reading, editing,
running tests, calling skills, and spawning subagents all happen *inside* it as
Python. State survives across turns AND compaction: the conversation can be
forgotten while the working data survives.

## The four design patterns (the reason Avi studies it)

1. **One tool, not a toolbox.** Flat model decision-space, unbounded power via
   new Python packages. New capability ≠ new tool description.
2. **Fire-and-forget subagents.** `handle = await rlm("task", name="x")` returns
   a child handle at admission, never the answer. Children reply via
   `await agent_message.send(msg, receiver_role="parent")`. Async by design.
3. **Self-improvement with a guardrail** (`/refine`): supplemental learning layer
   ABOVE an immutable base system prompt, snapshot-based rollback. Learning can
   edit notes, cannot ship itself new code.
4. **Autonomy as budgets + gates** (`/autonomous`): bounded turns/tokens/time
   plus a quality-gate command. Their honest line: *"reaching a limit does not
   imply task success."*

The three evaluation questions for ANY self-improving agent (see SKILL.md).

## Dockerfile (working)

```dockerfile
FROM node:22-bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates git \
    && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash prime
# Install globally as root (npm install -g needs /usr/local)
RUN curl -fsSL https://app.primeintellect.ai/prime-agent/install.sh | sh \
    && prime-agent --version
RUN mkdir -p /work && chown prime:prime /work
WORKDIR /work
USER prime
ENTRYPOINT ["/usr/local/bin/prime-agent"]
```

## Container lifecycle (the working sequence)

```bash
docker build -t prime-agent-lab .
docker volume create prime-lab-state
# Keep-alive container; override the Dockerfile ENTRYPOINT so `sleep infinity`
# is the main command (else it runs `prime-agent sleep infinity` and loops)
docker run -d --name prime-lab --restart unless-stopped \
  --entrypoint sleep \
  -v prime-lab-state:/home/prime/.prime -w /work \
  prime-agent-lab infinity

# Named volumes mount root-owned -> non-root user can't write sessions.
# Chown BEFORE recreating the run container:
docker run --rm -u root -v prime-lab-state:/data --entrypoint chown \
  prime-agent-lab -R prime:prime /data

# Kill telemetry (was on by default):
docker exec prime-lab bash -c 'cat > /home/prime/.prime/agent/settings.json <<EOF
{ "telemetry": { "enabled": false } }
EOF'
```

## TTY-aware host wrapper (/usr/local/bin/prime-lab)

```bash
#!/bin/bash
set -e
if ! docker ps --format '{{.Names}}' | grep -q '^prime-lab$'; then
  docker start prime-lab >/dev/null; sleep 1
fi
TTY_FLAG=""
if [ -t 0 ] && [ -t 1 ]; then TTY_FLAG="-it"; fi
docker exec $TTY_FLAG -w /work prime-lab /usr/local/bin/prime-agent "$@"
```

## OpenRouter auth wiring (reuse existing key, never echo it)

```bash
KEY=$(grep -E '^OPENROUTER_API_KEY=' /root/.hermes/.env | cut -d= -f2- | tr -d '"' | tr -d "'")
docker exec -u prime prime-lab bash -c "umask 077 && mkdir -p /home/prime/.prime/agent && cat > /home/prime/.prime/agent/auth.json <<'EOF2'
{ \"openrouter\": { \"type\": \"api_key\", \"key\": \"$KEY\" } }
EOF2
chmod 600 /home/prime/.prime/agent/auth.json"
```

Verify end-to-end: `prime-lab -p "Reply with exactly: live"`.

## Provider support

Subscription: `/login` → Claude Pro/Max, ChatGPT Plus/Pro (Codex), GitHub
Copilot. API key (env var or `auth.json`): Anthropic, OpenAI, Prime Inference,
DeepSeek, Gemini, Mistral, Groq, OpenRouter, xAI, and more. Auth file takes
precedence over env vars.

## Config layout

- `~/.prime/agent/auth.json` — credentials (0600)
- `~/.prime/agent/settings.json` — config (telemetry, skills)
- `~/.prime/agent/sessions/*.jsonl` — session transcripts
- `~/.prime/agent/skills/` — skills; project `.prime/agent/skills/`
- `~/.prime/agent/keybindings.json` — keybindings
- `AGENTS.md` / `CLAUDE.md` — project instructions (loaded at startup)

## Key interactions (v0.7.2)

- `/refine` self-improvement, `/goal` persistent objective, `/heartbeat` /
  `prime-agent schedule` recurring prompts, `/autonomous` bounded runs
- `/model` switch (Ctrl+L), `/effort` reasoning level, `/usage` cost/context
- `prime-agent list` / `attach` / `stop` / `shutdown` — daemon-backed workers;
  closing the TUI detaches, doesn't stop work
- One-shot: `prime-agent -p "..."`; pipe stdin; `--mode json` / `--mode rpc`

## Trust model (verbatim intent)

The IPython kernel runs model-generated Python and project commands with the
worker's OS permissions. **It is a durable control environment, not a security
sandbox.** Review third-party skills; use an external sandbox/VM for untrusted
repos. Run it only in the disposable container.

## Manual

Full user-friendly manual lives in the vault at
`Atlas/Lab/prime-agent-manual.md` (includes the §0 preamble frame). Official
docs: `packages/coding-agent/docs/{quickstart,usage,rlm,rlm-runtime,long-running-agents,skills,providers,keybindings}.md` in the repo.
