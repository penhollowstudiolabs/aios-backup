# OpenClaw Telegram channel — specifics & the work-wifi case

Session-specific detail behind the umbrella skill. Context: Hollow (OpenClaw 2026.7.1-2 on Avi's Windows laptop) went silent on Telegram on 2026-08-13.

## OpenClaw commands (Windows)

- `openclaw status` — gateway health, versions, probe (Running/Ready + probe ok = engine healthy).
- `openclaw models set <provider>/<model>` — sets `agents.defaults.model.primary` (e.g. `openclaw models set openrouter/deepseek/deepseek-v4-pro`). Verified command; preferred over hand-editing JSON.
- `openclaw models status` — shows Default / Fallbacks / auth profiles / quota.
- `openclaw gateway restart` — restarts the registered Scheduled Task (`OpenClaw Gateway`). A model config change needs this to apply (known quirk: not hot-reloaded).
- Config: `~\.openclaw\openclaw.json`. Gateway launch: `~\.openclaw\gateway.cmd` (launches `node.exe ...\openclaw\dist\index.js gateway --port 18789`).
- Log: `%LOCALAPPDATA%\Temp\openclaw\openclaw-<yyyy-mm-dd>.log` (one JSON object per line). Grep-able, e.g.
  `Get-Content "$env:LOCALAPPDATA\Temp\openclaw\openclaw-2026-08-13.log" -Tail 150 | Select-String -Pattern "deleteWebhook|webhook|sendMessage|Polling stall|starting provider" | Select-Object -Last 25`

## Log signatures of a network-blocked Telegram channel

- `telegram deleteWebhook failed: Network request for 'deleteWebhook' failed!`
- `deleteWebhook failed with a recoverable network error; continuing to polling so getUpdates can confirm webhook state`
- `[telegram][diag] isolated polling ingress started spool=...\telegram\ingress-spool-default`
- `Polling stall detected (active getUpdates stuck for 271s); forcing restart`
- `telegram message failed: Network request for 'sendMessage' failed!`
- `fetch fallback: primary connection path failed; trying alternative Telegram API IP (codes=ECONNRESET...)`

A restart loop where `starting provider (@Botname)` → `deleteWebhook failed` → `isolated polling ingress started` repeats identically on every boot = the channel cannot reach the Bot API (consistent network/init blocker).

## Red herrings hit this session (do not re-chase)

- **`.migrated` state files** in `~\.openclaw\telegram\` (`bot-info-default.json.migrated`, `update-offset-default.json.migrated`). Timestamps looked old (May/July) but `Rename-Item` doesn't touch LastWriteTime — so they could have been renamed recently. BUT the channel WORKED earlier the same day with those files present, so they were NOT the blocker. Do not rename them back on that evidence.
- **IPv6 dead route**: DNS returned an AAAA for api.telegram.org; `Test-NetConnection` to IPv4 (`149.154.166.110`) passed but IPv6 (`2001:67c:4e8:f004::9`) failed. Setting `NODE_OPTIONS=--dns-result-order=ipv4first` (setx + injected into gateway.cmd) did NOT fix it — because the real block was at the HTTP/TLS layer, not IP-family.

## The 2026-08-13 work-wifi case (confirmed root cause)

- Avi's **work wifi blocks HTTPS to `api.telegram.org` (the Telegram Bot API)** — at the HTTP/TLS layer. `Test-NetConnection` (TCP 443) passed; `Invoke-WebRequest "https://api.telegram.org"` failed with *"The underlying connection was closed: An unexpected error occurred on a send."*
- On Avi's **phone hotspot**, `Invoke-WebRequest` returned `200` and Hollow's channel reconnected and responded.
- **Consequences for Avi's setup (durable):**
  - Hollow (hosted on the laptop) cannot reach Telegram on work wifi → channel dead at work. Dashboard/webchat and phone hotspot are the workarounds.
  - Alyosha (hosted on VPS2/aios) is unaffected — runs from VPS2's network, not the laptop's.
  - Rule of thumb: agents hosted on the laptop inherit the laptop's network block; agents on a VPS do not.
  - Telegram's client protocol (MTProto) uses different servers than the Bot API, so Avi's own Telegram client still works on work wifi even while a laptop-hosted bot cannot get updates.
- This is stored in memory as the `Work wifi blocks HTTPS to api.telegram.org` fact; the diagnostic method lives in this skill.
