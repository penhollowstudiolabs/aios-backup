---
name: sandboxed-agent-harness
description: "Sandbox an open-source coding agent in Docker."
version: 1.0.0
author: Alyosha
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [agents, sandbox, docker, harness, rlm, prime]
---

# Sandboxed Agent Harness

How to stand up a **new open-source coding-agent harness** (Prime Agent, pi,
or any agent whose docs warn "this is not a security sandbox") in a **disposable
Docker container** for study and evaluation — without letting it touch the host.

The cardinal rule: these harnesses execute model-generated code with the
**operator's OS permissions** and explicitly disclaim being a security sandbox.
The container is the isolation boundary. Never point one at a precious repo or
real data on the host.

## When to use

- Avi flags an open-source coding agent to study (e.g. Prime Agent, the
  RLM-class harnesses) and wants it "in the lab."
- You need to evaluate an agent harness without committing the host.
- The upstream docs say anything like "process isolation is not a security
  sandbox" — that's the strongest signal to containerize.

## Core pattern

1. **Base image:** use the harness's required runtime. Prime Agent needs
   Node 22 → `node:22-bookworm-slim`.
2. **Install as root, run as non-root.** Harness installers often do
   `npm install -g` which needs `/usr/local`. Install as root, then create an
   unprivileged user and run the agent as that user.
3. **Confine work to a single `/work` dir** owned by the non-root user.
4. **Persist state via a named volume** (e.g. `prime-lab-state` at the harness
   config dir `~/.prime`) so sessions survive container recreation.
5. **Provide a TTY-aware wrapper** on the host (`/usr/local/bin/<name>`) that
   autostarts the container and adds `-it` only when stdin is a terminal.
6. **Kill telemetry** if the harness phones home by default.

See `references/prime-agent-lab.md` for the exact Prime Agent recipe (Dockerfile,
wrapper, auth wiring, and the four design patterns worth studying).

## Pitfalls (learned the hard way)

- **`docker build` fails inside a non-root `RUN` when the installer does a
  global npm install.** Fix: install globally as root in the image, but `USER`
  back to the non-root user for the agent's runtime. A `prime-agent --version`
  layer in the build verifies the install early.
- **`--entrypoint` beats `CMD`/`RUN`.** My Dockerfile had `ENTRYPOINT
  ["prime-agent"]`, so `docker run ... prime-agent-lab sleep infinity` tried to
  run `prime-agent sleep infinity` and the "keep-alive" container crashed
  looping. Fix: override entrypoint at run time with `--entrypoint sleep` so a
  `sleep infinity` is the main command.
- **Named volumes start root-owned.** Mounting an empty named volume at a
  non-root user's home makes it root-owned, so the harness can't write sessions
  (`EACCES` on `mkdir .../sessions`). Fix: `docker run --rm -u root -v
  <vol>:/data --entrypoint chown <img> -R <user>:<user> /data` before recreating
  the run container.
- **`docker exec -it` fails for non-interactive calls** ("cannot attach stdin to
  a TTY-enabled container"). Make the wrapper TTY-aware:
  `[ -t 0 ] && [ -t 1 ] && TTY_FLAG="-it"`.
- **First real run stops at auth — that's success, not failure.** The harness
  booting the kernel and reaching the provider gate means the sandbox is sound.
- **Harness auto-checks for updates/network at startup.** `PI_OFFLINE=1` /
  `PI_SKIP_VERSION_CHECK=1` where supported, and offline mode, keep a lab
  hermetic.

## Model/auth wiring in the lab

- Prime accepts a subscription login (`/login` OAuth) OR an API key via
  `~/.prime/agent/auth.json` or env var. Supports Claude, ChatGPT/Codex,
  GitHub Copilot, OpenRouter, DeepSeek, and many more.
- Wiring an existing key is the cheap path. Write `auth.json` with `umask 077`
  inside the container as the non-root user (0600). Reuse an existing key from
  `~/.hermes/.env` (e.g. `OPENROUTER_API_KEY`) rather than asking Avi for one —
  but never echo the key to output.
- Verify end-to-end with a one-shot prompt (`<wrapper> -p "Reply with exactly: ..."`)
  before reporting it ready.

## Deliverables for Avi

Avi values a **study manual**, not a pile of raw docs. After standing up a lab,
write a user-friendly manual into the vault (`Atlas/Lab/`), pulling the actual
upstream docs (quickstart, usage, model/runtime arch, skills, keybindings,
providers) — not just a video summary. Open it with a **§0 preamble** capturing
the strategic frame (why the lab exists), because for Avi the *why* is the
valuable part. Offer to email it to `avipenhollow@gmail.com` via AgentMail
(see `agentmail-integration` skill) from `system-alerts@agentmail.to`.

## The three questions for ANY self-improving agent

When a harness claims to "learn from sessions" (Prime's `/refine`), evaluate the
guardrail with:
1. **What can it not edit?** (immutable base / system prompt)
2. **Can you roll it back?** (snapshots)
3. **Can you read what it learned?** (plain files)

If it can't answer all three, it isn't self-improving — it's just changing.
