# Agent-provider cost measurement — what's automatable vs console-gated (8/16)

Ground truth after the 8/16 incident (Nous drained silently → fallback bled
OpenRouter). The honest data-source map: only **OpenRouter** has a working
API-measurable path. Everything else is console/laptop-gated and can only be
snapshotted by hand.

## The incident that motivated this
Nous Portal primary had NO measurable balance, drained to $0, and the downhill
fallback silently carried all model+web traffic on OpenRouter for ~18h before
anyone noticed. Both providers were nearly empty simultaneously (Nous $0,
OpenRouter ~$1.79 left). The system never "went down" — it bled the fallback
quietly. Lesson: an unmeasured primary + a shared fallback pocket = silent burn.

## Measurability by provider (verified 8/16 from live endpoints)
| Provider | API-measureable? | What works | Where it lives |
|---|---|---|---|
| **OpenRouter** | ✅ YES | `GET /api/v1/auth/key` → `data.usage` (USD to date), `limit`, `limit_remaining`; `GET /api/v1/credits` → `total_credits`, `total_usage`, remaining | VPS, autoatable |
| **Google** | ✅ | OAuth token, Drive `about` → storageQuota/user (not a burn concern) | VPS |
| **Anthropic** | ❌ NO | usage/balance endpoints 404 off the API key; **console-only** (`console.anthropic.com → Usage`). Manual snapshot only. | console |
| **Nous** | ❌ NO | no API balance endpoint at all; **Portal dashboard only** — permanent gap | portal |
| **ChatGPT/Codex** | ❌ NO | subscription plan page shows only `% remaining` + reset date + 0 credits; **no token counts, no spend** — it's a cap meter, not a report. Flat $20/mo (or $10-to-cap) regardless | laptop (Hollow's) + Avi's account |

**Key finding:** the ChatGPT/Codex subscription page is useless for accounting —
it shows no usage numbers at all. If real per-task figures are ever needed, the
heavy work must be routed to a **measurable lane** (OpenRouter or Codex API) before
it runs; it cannot be recovered from the subscription after the fact.

## The practical shape: NOT a dashboard
Only 1 of 5 lanes automates. Building a "dashboard" over console-gated sources
over-commits to manual entry and goes stale. The right shape (converged with
Hollow 8/16):
- **OpenRouter auto-feeds itself** → daily CSV (see below) + one silent night-watch
  guard that pings only on low balance (<$5) or abnormal burn-spike (> $8 jump).
- **Anthropic / Nous / Codex** → snapshot by hand only when you happen to look;
  proportionate since OpenRouter + Anthropic are the low-burn lanes and Nous is
  unmeasurable anyway.

## Standing pieces (live on aios)
- `openrouter_usage_snapshot` (cron, 5am PT, no_agent) → appends to
  `openrouter_usage_log.csv` under `Efforts/Captain-Avi-System/`. Read one file for
  the trend.
- `openrouter-night-watch` (cron, 3:30am PT, no_agent, silent-when-healthy):
  alerts once for low balance (<$5 crossing) or burn-spike (>$8).
- Scripts: `scripts/openrouter_usage_snapshot.sh`, `scripts/openrouter_night_watch.sh`
  in the alyosha profile.

## Verify caps are real, not notes
The "$25/mo OpenRouter cap" recorded earlier was a **note, not an enforced
limit** — `GET /api/v1/auth/key` returned `limit: null`. OpenRouter does not
expose a hard-limit-set API; limits are set in their dashboard (Keys → the key).
Never trust a recorded cap string as enforceable — check `limit` is non-null.

## Who builds/tracks what (per role calibration)
- Hollow = designated technical owner for VPS/profile/sandbox env; builds the
  tracking surface if any. His machine holds the Codex side only he can reach.
- Alyosha = continuity, reconciliation, the OpenRouter pipeline already running.
- Avi = consents, funds, and is the console-gated source for Anthropic/Nous/Codex
  snapshots.

## User notes (sensitive to Avi's frustration)
- "Don't generate so much crap when you can't even access basic information" — if a
  provider page/endpoint is unreachable (web tools down on empty Nous credits,
  portal rate-limited), say so in 1–2 lines and move on; don't pad with
  unverifiable prose or re-derive a table from memory. Cost-optimization sessions
  are where he's shortest.
- When web tools are down on the Nous/Firecrawl pocket, a cheap fallback is to
  `curl` an oEmbed or basic page (no credits) to grab a title, before declaring
  it un-auditable. Claude/Gemini via a paid lane also works but “ask the account
  holder” first if it's a number only they hold.