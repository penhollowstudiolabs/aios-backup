---
name: hermes-profile-orientation
description: "Use when orienting a Hermes agent after migration."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [hermes, profiles, migration, vps, orientation, multi-agent, config]
    related_skills: [hermes-agent]
---

# Hermes Profile Orientation

Use this skill when an agent needs to establish its own identity, locate its profile, verify provider config, or recover context after a VPS migration or fresh profile setup.

## When to Load

- First session on a new machine or after a VPS migration
- Agent is uncertain which profile it's running under
- User asks "what model are you on?" or "check your config"
- Provider mismatch suspected (e.g. OpenRouter vs direct API)
- No session history found — need to understand why

## Orientation Sequence

Run these in order. Don't skip ahead or assume results before you have them.

### 1. Confirm machine identity
```bash
hostname && ip route get 1 | awk '{print $7; exit}'
```

### 2. Read actual config — do NOT report from session header alone
```bash
cat ~/.hermes/config.yaml
```
The session header shows `provider:` and `model:` as metadata — but the **only authoritative source is the config file**. Always read it before reporting.

### 3. Locate active profile
```bash
ls ~/.hermes/profiles/
ls ~/.hermes/profiles/default/ 2>/dev/null || echo "no default profile dir — using ~/.hermes/ as root"
```

### 4. Find SOUL.md and MEMORY.md
```bash
find ~/.hermes -name 'SOUL.md' -o -name 'MEMORY.md' 2>/dev/null
```

### 5. Search session history for migration context
```
session_search(query="migration VPS profile setup")
```
Zero results = clean/new profile, not an error. Report honestly.

### 6. Check other VPS if needed (run from that machine, not SSH to self)
```bash
ssh root@<other-vps-ip> "find /root/.hermes -name 'AGENTS.md' -o -name 'SOUL.md' -o -name 'MEMORY.md' 2>/dev/null"
```

## Profile Layout

- **Default profile:** `~/.hermes/` directly (no `profiles/default/` subfolder)
- **Named profile:** `~/.hermes/profiles/<name>/` — own `config.yaml`, `SOUL.md`, `memories/`, `sessions/`, `skills/`
- A machine can have both a default profile AND named profiles simultaneously

## Pitfalls

### ❌ Never report config from session header without reading the file
The session header (`Provider: openrouter`, `Model: ...`) is injected metadata — it may lag behind actual config. Always `cat ~/.hermes/config.yaml` before making claims about what provider/model is active.

### ❌ Never fabricate or infer tool output
If a terminal call returns an orphan recovery error or empty output, **stop and say so**. Do not restate the session header as if it were config file output. Do not construct "consistent with X" explanations without real data. Report the blocker honestly.

### ❌ Don't explain away zero session history
Zero results from `session_search` is real data. State what you found; don't spin it into a coherent narrative about "new profile" or "migration" unless you have actual evidence.

### ❌ Don't conflate profiles across machines
A profile named `alyosha` on VPS 1 and `alyosha` on VPS 2 are independent. Confirm hostname before drawing conclusions.

## Switching Provider/Model

Use `hermes config set` — never hand-edit `config.yaml`:

```bash
hermes config set model.provider anthropic
hermes config set model.default <exact-model-string>
```

If the user gives a model string you don't recognize, ask for the exact provider and model string before making changes. Don't guess slugs.

## References

- `references/vps-migration-notes.md` — layout notes from the 2026-08-03 VPS 1 → VPS 2 (aios) migration
