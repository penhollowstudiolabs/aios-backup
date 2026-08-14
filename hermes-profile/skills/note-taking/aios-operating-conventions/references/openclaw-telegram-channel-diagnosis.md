# OpenClaw Telegram channel diagnosis — Hollow silent on Telegram (8/13)

When Hollow (OpenClaw gateway on Avi's Windows laptop, `DESKTOP-90RGNB6`, bot
`@Penhollowbot`, chat `8743718071`) gives ZERO reply on Telegram while other
things work, the gateway engine is usually healthy and the fault is the
Telegram channel / laptop egress. Diagnostic path proven 8/13.

## Step 0 — separate the two failure families

- **Slow replies** (they eventually come) → model inference over bloated
  context. See `references/slow-response-diagnosis.md`. NOT this case.
- **Zero reply at all** → channel or egress. THIS reference.

## Step 1 — confirm the process is alive, not that Telegram works

`openclaw status` shows a healthy gateway (Running / Ready / probe ok) even
when the Telegram channel is dead. Status is liveness of the engine, not of
the channel. A healthy status is expected and tells you nothing about Telegram.

## Step 2 — read today's log

Date-stamped, one JSON blob per line:
```powershell
Get-Content "$env:LOCALAPPDATA\Temp\openclaw\openclaw-2026-08-13.log" -Tail 100
```
Focused view:
```powershell
Get-Content "$env:LOCALAPPDATA\Temp\openclaw\openclaw-2026-08-13.log" | Select-String -Pattern "deleteWebhook|webhook|getUpdates|polling|starting provider|@Penhollowbot" | Select-Object -Last 30
```

## Step 3 — decode the signatures (the "smoking gun")

| Log text | Meaning |
|---|---|
| `getaddrinfo ENOTFOUND openrouter.ai` / `api.anthropic.com` | DNS resolution failing → egress outage window (work wifi / flap) |
| `[model-fetch] ... status=200` | That provider DID respond → network is flapping, not hard-dead |
| `Inbound message telegram:8743718071 -> @Penhollowbot` logged, then stops | Telegram was delivering, then egress died at the last timestamp |
| `Polling stall detected (active getUpdates stuck for 271s); forcing restart` | `getUpdates` fetch to Telegram hung → channel restarts itself |
| `deleteWebhook failed: Network request failed` repeated on every boot | **Connectivity failure to api.telegram.org, NOT a webhook conflict.** A webhook-vs-polling conflict returns a 409; these are ECONNRESET / request-timeout / ENOTFOUND |
| `isolated polling ingress started spool=...\telegram\ingress-spool-default` | Channel fell into degraded spool mode after the handshake failed |
| `Assertion failed: !(handle->flags & UV_HANDLE_CLOSING), file src\win\async.c, line 76` | Cosmetic libuv teardown noise at CLI exit, NOT a config error. Ignore unless it spams or the gateway dies with it |

When the `deleteWebhook failed` + `Polling stall` + `isolated polling ingress`
triple repeats across successive boots (e.g. 09:09, 09:21, 09:25, 09:30, 09:39,
09:44), the channel is **wedged in a restart loop** it can't escape while the
endpoint is unreachable.

## Step 4 — the dashboard-works-but-Telegram-silent tell

The OpenClaw **webchat/dashboard** routes through the model (openrouter etc.),
NOT the Telegram channel. So the dashboard replies while the bot stays silent.
That single fact isolates the fault to the Telegram channel + egress, and
exonerates the model/agent config. Ask Avi: "did it reply in the dashboard?"
- Dashboard replied → model path fine, Telegram channel is the fault.
- Dashboard silent too → model/agent path also broken (check model primary, e.g.
  a dead Codex/OpenAI binding forcing every call through fallback).

## Step 5 — prove connectivity from the laptop (PowerShell)

```powershell
Resolve-DnsName api.telegram.org
Test-NetConnection api.telegram.org -Port 443
Test-NetConnection 149.154.166.110 -Port 443        # raw IPv4 (bypass DNS)
Test-NetConnection 2001:67c:4e8:f004::9 -Port 443    # AAAA / IPv6 record
# same for LLM egress to see if fault is Telegram-specific or whole-egress:
Test-NetConnection openrouter.ai -Port 443
Resolve-DnsName openrouter.ai
```
Read the `TcpTestSucceeded : True/False` line. Test IPv4 AND IPv6 separately —
node may prefer the AAAA/IPv6 record, and a dead IPv6 route causes failures even
when IPv4 works (log line "primary connection path failed; trying alternative
Telegram API IP" is that signature).

**THE decisive test — TCP handshake vs actual HTTPS (add this to every probe):**
```powershell
(Invoke-WebRequest -Uri "https://api.telegram.org" -UseBasicParsing -TimeoutSec 10).StatusCode
# contrast: (Invoke-WebRequest -Uri "https://openrouter.ai" -UseBasicParsing -TimeoutSec 10).StatusCode
```
`Test-NetConnection` only proves the TCP handshake (layer 4). A network that
allows the handshake but blocks the TLS/HTTP request — **`Invoke-WebRequest`
fails with `The underlying connection was closed: An unexpected error occurred
on a send`** while openrouter returns fine — is a firewall at layer 7, NOT an
IPv4/IPv6 issue. This is the single test that ended the 8/13 chase. If the
HTTP test fails but openrouter's succeeds, the endpoint is network-blocked and
no config/IPv4/IPv6/state-file change fixes it.

## Step 6 — changing the primary model (the CLI way, no hand-edited JSON)

```powershell
openclaw models set openrouter/deepseek/deepseek-v4-pro
openclaw models status        # verify Default line
```
- Config lives in `~\.openclaw\openclaw.json` (`agents.defaults.model.primary`).
- A model config change needs a **gateway restart** to apply — known OpenClaw
  quirk (a config-only change doesn't hot-apply).
- Restart: `openclaw gateway restart`, else via Task Scheduler (gateway runs as
  a registered scheduled task launching `gateway.cmd`).
- `openclaw models status` also shows auth state — e.g. `openai:...OAuth ok
  expires in 5d` vs a `Codex binding generation was retired` error. A retired
  Codex binding = dead session, but LIVE credentials (`ok, 87% left`) mean
  re-linking (`openclaw models auth login`) is recoverable — don't assume the
  account is gone.

## Confirmed root cause (8/13, end of session) — work wifi blocks the Bot API

The 8/13 case was **not** OpenClaw, IPv4/IPv6, config, or state files. It was
Avi's **work (school-district) wifi blocking HTTPS to `api.telegram.org` (the
Bot API) at the TLS layer.** Evidence chain:

1. `Test-NetConnection api.telegram.org -Port 443` → `TcpTestSucceeded : True`
   (layer-4 handshake fine).
2. `(Invoke-WebRequest "https://api.telegram.org")` → fails, "connection was
   closed on send" (layer-7 blocked) while `openrouter.ai` returns fine.
3. On the **phone hotspot**, the same `Invoke-WebRequest` returned `200`, the
   gateway restarted, and **Hollow replied**. Confirmed.

Key facts this resolved:
- **`api.telegram.org` (Bot API) ≠ Telegram clients.** Telegram's *client*
  protocol (MTProto) uses different servers, so Avi can use the Telegram app on
  the laptop while the OpenClaw bot stays silent — don't be misled by "but
  Telegram works on the machine."
- **The webchat/dashboard bypasses Telegram entirely**, so it replies on the
  blocked network — the reliable work-wifi path to Hollow.
- **Hotspot is the fix.** Same as the VPN-block workaround Avi already uses.
  When on work wifi, tell Avi: use the dashboard, or hotspot the laptop.
- **The `openai/gpt-5.6-sol` Codex binding "retired" is a separate, secondary
  issue** (dead session, live creds) that forces fallback — worth re-linking
  (`openclaw models auth login`) but NOT the cause of the Telegram silence.
  Switching primary to `openrouter/deepseek/deepseek-v4-pro` removes the Codex
  dependency (do this via `openclaw models set`, see Step 6).

## Recurring pitfalls (learned the hard way)

1. **Defer to the machine's LIVE self-report over a stale log snapshot.** On
   8/13 I asserted the gateway hadn't restarted from a pasted log that ended at
   09:26; Hollow's live status showed ~6 min uptime — the restart HAD happened,
   and Avi told me I was wrong. If the machine has a live agent/status you can
   ask (Hollow is right there), ask it before trusting an older paste. Don't
   over-assert a single theory (e.g. "stale webhook wedge") before confirming
   with current connectivity evidence.
2. **`deleteWebhook failed: Network request failed` ≠ webhook conflict.** It's
   connectivity to api.telegram.org. Don't chase webhook-clearing until you've
   proven the API is reachable.
3. **Flapping egress is intermittent** — some requests 200, most fail. Run
   probes more than once. The cleanest recovery is a fresh gateway restart on a
   network you've *just proven* reaches Telegram; restarts during the flap all
   fail, so "restart didn't fix it" is not evidence the channel is broken.
4. **Webhook XOR polling:** a stale registered webhook blocks `getUpdates`
   polling. Rule it in only AFTER connectivity is confirmed clean.
5. **Restart-loop churn** from `Polling stall detected` is the channel cycling,
   not a crash — the gateway process stays up.
6. **`.migrated` state files are usually a red herring — and don't trust their
   timestamps.** Hollow spotted `bot-info-default.json.migrated` /
   `update-offset-default.json.migrated` under `~\.openclaw\telegram\` and
   theorized the plugin couldn't init without the originals. But the channel
   had been working all morning with those files exactly as-is, and
   **`Rename-Item` preserves `LastWriteTime`**, so an old timestamp does NOT
   prove the rename wasn't recent. Verify whether the channel worked WITH the
   files in that state before renaming anything back; a rename is reversible but
   risks writing stale state. Only act on this after connectivity is proven.
7. **Scheduled tasks don't re-read a just-`setx`'d user env var.** A fresh
   `setx NODE_OPTIONS ...` + `openclaw gateway restart` does NOT guarantee the
   new gateway process inherited it (the task host uses a cached env). If the
   env fix "didn't work," inject it into the actual launch — edit
   `~\.openclaw\gateway.cmd` to `set "NODE_OPTIONS=..."` before the `node.exe`
   line. (Forcing `--dns-result-order=ipv4first` was the 8/13 dead-end fix —
   see pitfall 8.)
8. **Don't chase IPv4/IPv6 when the HTTP-layer test shows a firewall.** On 8/13
   we spent a long stretch on the IPv6 theory (dead AAAA route, node preferring
   IPv6, `--dns-result-order=ipv4first`). It was DISPROVEN: `deleteWebhook`
   still failed after the IPv4-first fix applied. The moment `Invoke-WebRequest`
   to the endpoint fails while `openrouter` succeeds, stop the
   config/IPv4/IPv6/state-file work — it's a network firewall and only a
   different network path (hotspot) or the dashboard fixes it.
