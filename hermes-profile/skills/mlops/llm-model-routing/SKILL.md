---
name: llm-model-routing
description: Inspect an agent's LLM model+provider & switch it.
---

# LLM Model & Provider Routing

## When to use
- User asks "what model/provider is this agent running?"
- User wants to point an agent at a different model (e.g. a new DeepSeek, an upgraded Claude) or a different provider.
- User asks whether a new model requires a new API key.
- Auditing model routing across multiple agents/profiles.

## Core mental model: provider vs. model vs. key
- **Provider** = the front door / API you authenticate against (e.g. OpenRouter, Anthropic, OpenAI, Nous Portal).
- **Model** = a specific model ID on that provider (e.g. `anthropic/claude-sonnet-4-6`, `deepseek/deepseek-v4-flash-0731`).
- **Key** = credentials for the provider, NOT per model.

### OpenRouter is the unified front door
A single `OPENROUTER_API_KEY` (prefix `sk-or-...`) authorizes *hundreds* of models — including DeepSeek, Claude, GPT — through one endpoint. **You do NOT need a separate DeepSeek/Anthropic key to use those models when the provider is OpenRouter.** To try a new model: just reference its model ID. No new credentials.

This is why "evaluate DeepSeek across agents" is a trivial swap, not a credential project.

### Nous Portal is a fourth provider door (house product of Nous, the Hermes makers)
Sign-in / OAuth: `hermes setup --portal` — one OAuth covers the model catalog + the Tool Gateway (web search, image gen, TTS, browser). Catalog carries 200+ models incl. the same DeepSeek V4 models Avi routes via OpenRouter. It is a **subscription cadence** (monthly credit meter + rollover cap), NOT pay-per-token like a direct API. For a cost-conscious operator: a Free-tier Portal account is cheap "seize-to-look"; don't migrate routing to Portal on an *unverified* promo. Full plan tiers + pricing-grab method + economics: `references/provider-pricing-and-portals.md`.

## Where the active model actually lives (check, don't guess)
Model selection is layered. Always inspect the real files before answering:

1. **Config file default** — `~/.hermes/.../config.yaml` under `model:`:
   ```yaml
   model:
     default: anthropic/claude-sonnet-4-6
     provider: openrouter
   ```
2. **Per-chat / runtime override** — a session can be switched without touching the file. The operating model may differ from `config.yaml`. When asked "what model am I on", the *active* answer is the runtime one; the config is the *default going forward*.
3. **Provider keys** — `~/.hermes/.../.env`, grep `OPENROUTER|ANTHROPIC|DEEPSEEK|NOUS`. Comments in this file explain routing intent.

### Quick inspection commands
```bash
# model section of the profile config
grep -iA5 "model:" ~/.hermes/profiles/<profile>/config.yaml

# which provider keys are set (masked)
grep -iE "OPENROUTER|DEEPSEEK|ANTHROPIC|NOUS" ~/.hermes/profiles/<profile>/.env | sed -E 's/(=.{6}).*/\1.../'

# CLI-facing summary
hermes config show | grep -iE "provider|model"
```

## Fallback chains: the silent quality cliff
The fallback chain matters as much as the primary. A provider-capacity blip (e.g. HTTP 503 "upstream capacity limits" on the nous route to DeepSeek) makes Hermes silently fall back — and if the fallback is a lite-tier model, replies degrade to garbage with no visible error. This exact failure (gemini-2.5-flash-lite as DeepSeek's fallback) destroyed a whole morning for Avi on 2026-08-09.

Rules that came out of it:
- **Fallback must match the primary quality tier.** Never a lite-tier model as a main agent's default fallback.
- **Preferred fallback for a capacity problem: the SAME model via a different provider.** Same weights, different pipe — Nous is one route to DeepSeek; OpenRouter serves the same model ID from multiple upstream hosts, so it fails over *within the model* instead of dropping quality.
- **Provider capacity ≠ model quality.** 503s on the nous route mean the provider's route is saturated, not that the model is bad.
- **Review the fallback chain with the same scrutiny as the primary** during any routing review — this is exactly where it gets missed.

Full commands, the non-interactive `hermes config set fallback_model.*` recipe (incl. the false-positive "not a recognized config key — did you mean fallback_providers" warning), and the log-grep diagnosis pattern: `references/hermes-fallback-chain.md`.

## Pitfalls
- **Don't assume a model needs its own key.** If the provider is OpenRouter, the one OpenRouter key covers it. Check provider first.
- **Don't answer "what model am I on" from memory or from the config file only** — a per-chat override may be active. Acknowledge the distinction between the runtime model and the config default.
- **Per-chat switch ≠ global change.** Changing one session does not affect other sessions/agents; each reads its own config/override. Say this explicitly when asked.
- OpenClaw does **not** centralize model config in `openclaw.json` (that file holds gateway/auth only). Its model comes from elsewhere (env vars, per-agent/session config). Inspect env + agent scope, don't assume a central config field exists.
- Some providers are 'auto' routed through OpenRouter rather than direct — confirm the actual route in config rather than assuming a direct provider key.

## Auxiliary models are a SEPARATE layer from the main chat model
Auxiliary tasks (vision/image analysis, compression, session_search) run on their own model, configured independently of the main `model:` block. Setting the main model (or having a provider key) does **not** automatically give auxiliary tasks a provider.

**Symptom:** `vision_analyze` fails with `No LLM provider configured for task=vision provider=auto. Run: hermes setup` — even when the main model/provider are perfectly configured.

**Fix (must set BOTH provider and model explicitly):**
```bash
hermes config set auxiliary.vision.provider anthropic
hermes config set auxiliary.vision.model anthropic/claude-sonnet-4-6
```
Verify: `sed -n '/auxiliary:/,/^[a-z]/p' ~/.hermes/profiles/<profile>/config.yaml`. A config change requires a fresh session / gateway restart to take effect (see hermes-agent troubleshooting). Rationale pattern that recurred with Avi: route the cheap main model (DeepSeek via OpenRouter) for normal chat to save tokens, but point a single auxiliary task (vision) at a reliable paid model (Anthropic) — one isolated override, not a global switch.

## User preference (Avi)
When Avi asks how a model/provider is configured, **verify against the actual config/env and report the exact fields** rather than reciting theory. He is technical enough to act on precise findings and gets frustrated by guesses, workarounds, and over-explanation. Give the concrete command + what it returns, then the one-line mental model.
- **Ask before touching routing/fallback config.** He corrected this explicitly: *"You need to ask me before configuring anything with model routing or fallbacks."* Even read-only probing of routing config should be preceded by saying what you're checking and why. State the plan, get the go, then change.
- **Never default a main agent to a lite-tier fallback.** *"Alyosha should NEVER default to such a shitty model."* Fallback quality must match primary.

## Verifying WHICH key is real, not just "a key is present"
Provider accounts can hold several keys; a key existing on the account is NOT the same as it being wired into an active config. When a user shares an account export/screenshot, reconcile it against the actual `.env` files:
- Match by the **last 4 chars** of the API-key body (masked grep shows `...aAAA` vs `...AQAA`).
- Prove the wired key authenticates with a real tiny call — see `references/verified-key-credential-audit.md`.
- **Anthropic exposes NO public REST endpoint for API-key credits/balance** — that data is console-only. Don't fabricate a balance.
- A JSON export and a console screenshot can show different balances/spend/caps because they're **two separate wallets** (API workspace vs Claude plan) under one login — reconcile by naming which view each number is from, not by picking a "winner".

## References
- `references/provider-pricing-and-portals.md` — Nous Portal plan tiers + `hermes setup --portal` OAuth, the DeepSeek-pricing curl gotcha, cache-hit economics (long sessions get cheap), the one-active-surface cost rule, and the keys-vs-subscriptions-vs-portals map for explaining to Avi.
- `references/avi-stack-inspection.md` — verified example of inspecting Avi's two-VPS + laptop stack, incl. the OpenClaw `openclaw.json` gotcha.
- `references/verified-key-credential-audit.md` — procedure for matching the wired key to an account key list, proving it works, and reconciling API-console vs Claude-plan credit views.
- `references/hermes-fallback-chain.md` — the 2026-08-09 quality-cliff incident: log-grep diagnosis, non-interactive `fallback_model.*` config recipe, the false-positive config warning, and Avi's fallback rules.
