---
name: self-hosted-agent-troubleshooting
description: "Use when a self-hosted agent's chat channel goes silent."
version: 1.0.0
author: Alyosha
license: MIT
platforms: [linux, windows]
metadata:
  hermes:
    tags: [debugging, telegram, openclaw, network, self-hosted, bot, channel, egress]
---

# Self-Hosted Agent Troubleshooting (silent channel / lost context / model outage)

Systematic method for when an agent you host (e.g. Hollow/OpenClaw on a laptop, or any bot on a VPS) stops responding on a messaging channel — most often Telegram — OR is up but behaving as if it lost context ("amnesia"), OR is affected by a model/provider/credits outage. The whole craft is **isolating the failing layer before changing anything**, because the wrong theory burns hours.

## Three distinct failure modes (diagnose which one before acting)

1. **Channel silent** — engine healthy but no replies on Telegram. See Core method below (network/TLS scope). Dashboard-replies-but-Telegram-silent = channel scope.
2. **Agent up but confused ("amnesia")** — replies but has lost recent context/decisions. This is **session/context loss**, not a channel or engine fault. Fix = re-orient from the shared source of truth (the vault), NOT a restart. The agent's own session memory is unreliable after a disruption; the vault is authoritative. Send a **re-orientation message** restating: what was actually accomplished (from the vault record, citing real commits/state), who witnessed it, and that the agent is not broken. Point it back to the vault as its memory. This has worked repeatedly (2026-08-13, 2026-08-14).
3. **Model/provider/credits outage** — engine healthy, channel fine, but replies fail or degrade because a model/provider upstream is out (credits exhausted, binding retired, quota). See Model outage section below.

## Core method (do in order) — channel silent

1. **Confirm the engine is alive first.** Run the agent's status command (`openclaw status`, or equivalent). If the gateway/process is `Running`/`Ready` and the connectivity probe passes, **the engine is not the problem** — stop debugging it. A healthy status + silent channel = channel or network scope, not the agent.

2. **Isolate channel vs model path.** Does the agent's web dashboard / webchat reply?
   - Dashboard replies but Telegram is silent → the model+agent path is fine; the problem is **specific to the Telegram channel or its network egress** (the dashboard never touches Telegram).
   - Dashboard silent too → the running process itself is broken; a restart is mandatory.

3. **Network-layer discriminator — THE key move.** Test TWO different layers against the bot API endpoint:
   - TCP + DNS: `Test-NetConnection api.telegram.org -Port 443` and `Resolve-DnsName api.telegram.org`
   - Actual HTTP: `(Invoke-WebRequest -Uri "https://api.telegram.org" -UseBasicParsing -TimeoutSec 10).StatusCode`
   - **CRITICAL:** a passing TCP handshake does NOT mean HTTP works. If `Test-NetConnection` passes but `Invoke-WebRequest` fails (e.g. *"The underlying connection was closed: An unexpected error occurred on a send"* / TLS error), the endpoint is **blocked at the HTTP/TLS layer** — firewall/proxy/MITM. That is not fixable with IP-family or agent config.
   - Run a **control endpoint** that is known-good (e.g. `https://openrouter.ai`). If the control works and the target fails, it is endpoint-specific blocking.

4. **Read the agent's own log for the signature.** Persistent channel errors (`deleteWebhook failed`, `sendMessage failed`, "Network request failed", `fetch failed`, ECONNRESET) or a polling stall that forces a restart loop = the channel cannot reach the API. A channel that re-initializes and fails identically on every boot = consistent network/init blocker, not a transient.

5. **Webhook-conflict vs network — don't conflate.** A webhook conflict yields a `409`/conflict error *from the API*. Persistent "Network request failed" / "fetch failed" = network, NOT webhook state. Don't chase webhook-clearing when the errors are network-shaped.

6. **Verify network is genuinely up BEFORE restarting.** Don't hammer `gateway restart` hoping it heals a block. Prove HTTP works first (step 3), then restart once. A restart on a still-blocked network just re-fails identically.

## Model/provider/credits outage (agent up, model path broken)

When an agent's replies fail/degrade but the engine and channel are healthy, suspect the **model routing path**, not the agent.

- **Identify which provider the agent actually bills.** Direct-vendor API keys (Anthropic `sk-ant-…`, OpenAI) are separate from credits routed through a reseller (OpenRouter, Nous). An exhausted direct Anthropic balance kills ONLY things bound to that direct key (e.g. Claude Code), NOT agents whose model string routes via OpenRouter (`anthropic/claude-sonnet-4-6` with `provider: openrouter` bills OpenRouter, not the direct Anthropic key).
- **Check the agent's current model chain** before changing anything: `openclaw models status` (primary + fallbacks). Never assume — read it.
- **The dangerous configuration is a fallback pointing at an exhausted DIRECT key.** If the primary hiccups, the agent cascades to the dead fallback and goes silent — looks like "it broke" but is really a misrouted fallback. Stabilize by: (1) hard-set a known-good primary (e.g. `openclaw models set openrouter/deepseek/deepseek-v4-pro`), (2) ensure any Claude/OpenAI fallback routes through OpenRouter, not a direct vendor key, or drop it, (3) `openclaw gateway restart` (config change requires restart).
- **Reachability constraint:** a peer agent hosted on the laptop (`avi-laptop`) has **no SSH open** — you cannot read/change its config from the VPS. Route through the AgentMail lane to message the agent, and walk the human operator through `openclaw models …` manually on the laptop. Keep a lane open while the operator applies it.
- Keep the fix minimal when time-critical: stabilize on whatever works (DeepSeek via OpenRouter), park re-linking/deferred work for later.

## Pitfalls / verified red herrings

- **IPv6 dead route ≠ the cause of an HTTP block.** Forcing `--dns-result-order=ipv4first` (via `NODE_OPTIONS` or `gateway.cmd`) does NOT fix an endpoint blocked at the HTTP/TLS layer. Confirm with the actual HTTP test before touching IP-family settings.
- **A `Rename-Item` does NOT update `LastWriteTime`.** Don't use file timestamps to date a rename (stale-looking `.migrated` state files can have been renamed today while showing old content timestamps). But: if the channel WORKED earlier in the same day with those files present, they are not the blocker.
- **Bot API can be blocked while the client protocol works.** A firewall can block `api.telegram.org` (Bot API) while Telegram's client protocol (MTProto) reaches different servers. So a user can message you on Telegram while their own hosted bot on that same machine cannot get updates.
- **"You respond, bot doesn't" is not proof.** If you (an agent on a different host/VPS) answer while their bot is silent, that says nothing about their network — you run elsewhere. Only test from the bot's actual host.
- Don't conclude "config / bot-token broken" when the dashboard works. The scope is the channel, not the agent.

## References
- `references/openclaw-telegram-channel.md` — OpenClaw-specific commands/log signatures + the work-wifi network-block case (2026-08-13).
