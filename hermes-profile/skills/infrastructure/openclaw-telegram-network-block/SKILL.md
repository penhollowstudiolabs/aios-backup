---
name: openclaw-telegram-network-block
description: "Hollow silent on Telegram? Diagnose api.telegram.org block."
version: 1.0.0
author: Alyosha
license: MIT
platforms: [windows]
metadata:
  hermes:
    tags: [openclaw, hollow, telegram, network, debugging, bot-api]
---

# OpenClaw/Hollow Telegram Outage — Debug (network-block pattern)

When Hollow (OpenClaw on the Windows laptop) stops responding on Telegram, the #1 cause in Avi's environment is **the work wifi blocking HTTPS to `api.telegram.org` (the Telegram Bot API)** — NOT an OpenClaw/config problem. This skill gets to that answer in minutes instead of an hour.

## Key facts (Avi's environment)

- Hollow = OpenClaw gateway on the **laptop** (Windows, `~\.openclaw`). Runs as a **Scheduled Task** (`OpenClaw Gateway`), launched via `gateway.cmd`.
- The laptop is **normally at home** — the network block only bites when the laptop is **brought to work** (rare). At home Hollow's network is fine.
- The **dashboard/webchat UI works even when Telegram is dead** — because it never touches Telegram. That's the single best tell.
- Hollow/OpenClaw is reachable at the dashboard `http://127.0.0.1:18789/` regardless of the Telegram channel.
- AgentMail coordination lane: Hollow↔Alyosha via `coordination@agentmail.to` (Hollow reads/sends `system-alerts@agentmail.to`).

## The core discriminator

`Test-NetConnection` (TCP handshake) can SUCCEED while the actual HTTPS request FAILS. A firewall can allow the TCP 443 handshake but block the request at the TLS/HTTP layer. So:

1. **Dashboard replies?** → gateway + model are fine; only the Telegram channel is affected.
2. **`Test-NetConnection api.telegram.org -Port 443` = True** → TCP is up.
3. **`Invoke-WebRequest -Uri "https://api.telegram.org" -UseBasicParsing`** → if this FAILS ("underlying connection was closed") while openrouter works → **network block on the Bot API confirmed.** Not fixable in OpenClaw.

## Debug workflow

```powershell
# 1. Confirm the engine is healthy (it usually is)
openclaw status
#   - Runtime: running, state Ready, connectivity probe ok  → engine fine

# 2. Engine-healthy but Telegram silent → network discriminator
(Invoke-WebRequest -Uri "https://api.telegram.org" -UseBasicParsing -TimeoutSec 10).StatusCode
#   - 200/404 = network open (look at OpenClaw config/state instead)
#   - "connection closed" error = Bot API blocked by the network

# 3. Confirm it's a network block, not OpenClaw, by testing a working endpoint
(Invoke-WebRequest -Uri "https://openrouter.ai" -UseBasicParsing -TimeoutSec 10).StatusCode
#   - openrouter OK + telegram fails = network block on telegram only

# 4. Check the OpenClaw log for the recurring signature
Get-Content "$env:LOCALAPPDATA\Temp\openclaw\openclaw-YYYY-MM-DD.log" -Tail 200 | Select-String "deleteWebhook|starting provider|Polling stall|getUpdates"
#   - Repeated "deleteWebhook failed: Network request failed" + "Polling stall" + "isolated polling ingress" across restarts = telegram can't reach the API
```

## Fixes / workarounds

- **Phone hotspot** — bypasses the work block; Hollow reconnects automatically. (Avi's go-to.)
- **Dashboard/webchat** — works on the blocked network; the reliable fallback.
- No OpenClaw config, restart, or state-file change fixes a network block.

## Red herrings (proven NOT the cause — do not re-chase)

- **IPv6 / `NODE_OPTIONS=--dns-result-order=ipv4first`** — the IPv6 route to api.telegram.org is dead on Avi's work wifi, BUT forcing IPv4-first does NOT fix the block (the block is HTTP/TLS-level, not IP-family). A harmless `set NODE_OPTIONS=--dns-result-order=ipv4first` line may be in `gateway.cmd` — can stay or go.
- **`.migrated` telegram state files** (`~\.openclaw\telegram\bot-info-default.json.migrated`, `update-offset-default.json.migrated`) — old leftovers, NOT the cause. Do NOT rename them back.
- **Model config** — if the dashboard replies, the model is fine. Don't rebuild the model/fallback chain.

## Pitfalls

- `setx NODE_OPTIONS` to a user env var does NOT reliably reach a Scheduled Task process (task host uses a cached env). Not worth fighting — it's a red herring anyway.
- Avi can still use Telegram's client (MTProto) on a network that blocks the Bot API — so "he can message me" does NOT mean the Bot API is reachable from the laptop.
- The gateway restarts itself in a loop when the Telegram channel can't init ("starting provider" + "deleteWebhook failed" repeating) — that churn is a symptom, not a separate fault.

## Verified fix (2026-08-13)

On the hotspot, `Invoke-WebRequest https://api.telegram.org` returned 200 and Hollow reconnected. Root cause confirmed as the work-wifi block on the Bot API. Hollow was never broken.
