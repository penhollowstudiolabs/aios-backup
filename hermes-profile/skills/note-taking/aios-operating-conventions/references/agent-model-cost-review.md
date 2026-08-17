# Agent-model cost review — routing, subscriptions, and the 8/2026 DeepSeek increase

## Why Nous was chosen — and how it drifted (origin + the 8/16 exhaustion, durable)
**Origin (8/4):** Nous Portal was chosen as ALYOSHA'S PRIMARY because it was framed as *"Nous Research's subscription that routes to 300+ models through one subscription"* — one predictable door to many models. The intent was a single flat consolidation play, the same instinct as Avi's recurring "know how much this will cost" goal.

**The drift that caused the 8/16 outage:** the plan was never actually purchased as a subscription. The tracking file records Nous as **"$5 top-up, NO subscription"** (8/7) — a pay-as-you-go pocket that carries none of the original "one predictable door" properties:
- **Not measurable from the API** (no balance/usage endpoint; blank). The dollar figure lives only in the Nous Portal web dashboard — the one known blank in the ~$100/mo budget.
- **Model + managed web tools share the same pocket**, so draining it kills BOTH. `web_extract`/`web_search` run through Nous's managed gateway, which additionally wants an ACTIVE SUBSCRIPTION (you have none — pay-as-you-go only) → `SUBSCRIPTION_REQUIRED`.
- **Silent exhaustion → paid-fallback leak.** When Nous hit 0 (`404: account balance is too low`), an auxiliary task fell back to **OpenRouter `claude-sonnet-4-6` (a PAID model)** at ~2:26am, burning real spend on the OpenRouter bill in the same motion as failing.
- Downstream: every agent turn + cron run (3:00am power-tech, 5:30am Daily Brief) started failing ~12:17am PT 8/16. First-ever `requires available credits` = 2026-08-16 07:17 UTC.

**Durable guard (config candidate, flag to Avi):** cap auxiliary/fallback to `:free` models only — `auxiliary.free_only: true`, or `auxiliary.openrouter_model` to a `:free` SKU — so an exhausted primary can't silently bleed money onto a second paid lane. **Routing is Avi-gated: do NOT change model/provider/web routing without asking.**

**The decision to offer Avi — two ways to restore the ORIGINAL "one place, everything" intent:**
- **(A) Buy the actual Nous SUBSCRIPTION — NOUS PLUS = $20/mo, $22 credits included, $10 rollover cap, 400 RPM / 4M TPM** (confirmed 8/16 via Gemini, Avi). The three paid tiers: Plus $20 (→$22 creds), Super $100 (→$110), Ultra $200 (→$220); ~10% credit bonus applies to inference AND bundled tool APIs (web search/image-gen) AND Hermes Cloud hosting. The "rotational $5" was a TOP-UP, never a subscription. Restores "300+ models through one sub" + flattens web-tool cost into a known fixed $20.
- **(B) Consolidate on OpenRouter**: also one door, already capped and measurable via `/api/v1/auth/key` → `data.usage` (and `GET /api/v1/credits` → `total_credits`/`total_usage` for the true remaining balance). No new purchase. Trades Nous for the provider we already measure.
Both honor "one door." Avi's principle from the session holds: **know the cost; don't patch.**

## 8/16 audit outcomes — ACTUAL DECISIONS (supersede the "candidate/config flag" notes above)
The live audit (Alyosha + Hollow, Avi-steered) converged and Avi decided:
- **Primary model moved to OpenRouter** (`deepseek/deepseek-v4-flash-0731` via openrouter, explicit model). Approved 8/16. (Config lives at `model.provider=openrouter`.)
- **Crons repinned to openrouter** — Daily Brief (`a85b2d174ce5`) + agent-stack-scan (`eec69acfb986`). **Watch the `provider_snapshot` in cron/jobs.json**: re-pinning the global provider does NOT auto-update jobs' stored `provider_snapshot`; a stale `nous` snapshot makes a job FAIL CLOSED on next run. Fix via CLI: `hermes cron edit <id> --model <m> --provider openrouter` (the agent's `cronjob update` tool does not accept provider — use the CLI).
- **OpenRouter funded + watched.** Avi added $20 on 8/16 (credits 21 → 41). `GET /api/v1/credits` showed `total_credits=21, total_usage=19.21, remaining≈1.79` before top-up — a **near-total drain**, the SECOND lane that was silently about to run dry. A **daily usage snapshot cron** (`openrouter-usage-snapshot`, no_agent, silent, appends to `Efforts/Captain-Avi-System/openrouter_usage_log.csv`) now logs the trend; read one file, don't hunt the dashboard.
- **The "$25/mo cap" was a NOTATION, not an enforced limit** (Hollow's catch): `GET /api/v1/auth/key` returned `limit: None`. OpenRouter does **not** expose a hard-limit SET endpoint via API — a real cap is a dashboard click (Keys → key → limit), not something the agent can set. Do not claim a cap is enforced when it's only recorded.
- **"Auxiliary/fallback → :free" guard: candidly debated, then the monkey is off** — rather than rely on it, the resolution was to fund the measured lane (a real balance on OpenRouter) and stop treating the unmeasurable Nous pocket as production-critical. Those wanting the `claude-sonnet-4-6` paid-fallback leak eliminated should add an explicit `:free`-only auxiliary policy; Avi did not, choosing instead to keep OpenRouter the sole funded model lane.
- **Web tools were NOT funded** (no Firecrawl key, no Nous Plus). So `web_search`/`web_extract` stay DOWN on aios. Power & Tech Watch + agent-stack-scan's web legs are affected. **Web-sourced Power & Tech duty moved to Hollow** (residential IP reads the web freely; Avi 8/16): Hollow writes his dated scan to `/root/vault/Calendar/Power-Tech-Watch/<date>.md` and the 5:30am brief folds in the most-recent file — cost-free, no Firecrawl. My aios P&T cron (`e78cdf4f5981`) was **paused** (it was web-dead anyway). THE KEY LESSON: if the web lane is unfunded, route web-reaching work to the agent (Hollow) who has residential egress instead of funding a new tool.
- **Provider-health "watchdog" — RETIRED, and the design lesson is the opposite of what you'd expect.** I built a 15-min provider-alert cron during the incident; Avi judged it *excessive* ("it's usually in the middle of the night when things go wrong") and deferred it to me — and I retired it. The right detection surface for a doodle/ALWAYS-EVENING user is **the Daily Brief's system-health section** (it caught the exhausted-credits gap that morning without any buzzer), NOT a mid-night pager that alerts while asleep. **Do not add a frequent pager; make the morning brief the one health-check floor.**
- **Double-spend lesson (8/16):** a SPED build was done on Claude Code (VPS), but its iterative sessions ran INSIDE ChatGPT, and **Hollow was along for the same process** — pulling the ChatGPT/Codex **subscription at nearly every turn from two users**, doubling usage on a FLAT plan until it hit 0% / "codex limit reached" mid-week. **Avi: avoid running two agents against one flat-subscription paid lane on the same task.** The ChatGPT/Codex usage UI shows only `% remaining` + reset date (`Resets Aug 19 8:49 PM`) + `0 credits` — **it exposes NO token counts or per-task spend**; the plan is a cap meter, not a spend report. If per-use numbers matter, route the heavy work through a measurable lane (Codex API / OpenRouter), not the flat plan.

## Canonical source
`Efforts/Captain-Avi-System/Model-Token-Usage-Tracking.md` is the durable
per-agent routing/wallet record. Read it (and cross-check `Current Workboard.md`
+ Re-Entry) BEFORE asking Avi about models/costs.

## Baseline routing (from the vault, 8/05 + 8/14 deltas)
- **Alyosha** (me, VPS2): `deepseek/deepseek-v4-flash-0731` via Nous Portal
  primary; same model via OpenRouter fallback; vision `google/gemini-2.5-flash`
  via OpenRouter.
- **Hollow** (laptop/OpenClaw): `openai/gpt-5.6-sol` primary (Codex sub OAuth);
  F1 `deepseek-v4-pro` via OpenRouter; F2 `claude-sonnet-4-6`. **8/14:** his
  direct-Anthropic leg ran out of credits and went quiet; stabilized by setting
  primary on a working provider and moving direct-vendor fallbacks to
  OpenRouter (see `model-routing-fallback.md` / the Anthropic-key section).
- **Mayumi/ilocos** (VPS1): `deepseek-v4-flash-0731` via OpenRouter primary,
  `deepseek-v4-pro` fallback (off Gemini 8/10).

## Wallets (vault baseline, ~8/10)
- Anthropic API (`claude-code-vps`): ~$14 balance, **$15 auto-reload** — feeds
  Claude Code on the VPS only (not the agents).
- Claude.ai **Pro plan $20/mo** (corrected 8/9 — was never $100/mo). Promo
  credits expire **Sep 19** (use-or-lapse decision at recalibration).
- OpenRouter: single key.
- Nous Portal: primary for Alyosha.
- Avi's total mental budget: ~$100/mo across subscriptions + API.

## DeepSeek price increase — announced 8/13, effective 16:00 UTC 2026-08-16
Source: Reuters (8/13), official api-docs.deepseek.com/quick_start/pricing.
V4-Flash and V4-Pro, plus new **peak/off-peak billing**.

Peak hours: **01:00–04:00 and 06:00–10:00 UTC** (= 6pm–9pm & 11pm–3am Pacific).
Off-peak = half of peak.

Per 1M tokens:

| Model | tier | input cache-hit | input cache-miss | output |
|---|---|---|---|---|
| v4-flash | off-peak | $0.007 | $0.22 | $0.66 |
| v4-flash | peak | $0.014 | $0.44 | $1.32 |
| v4-pro | off-peak | $0.022 | $0.66 | $1.98 |
| v4-pro | peak | $0.044 | $1.32 | $3.96 |

**Vs. prior:** flash output $0.28 → $0.66 (~136% up); pro output $0.87 → $1.98
(~128% up). Cache-hit input up ~1000%+ (the "1,114%" Reddit figure — dollar
impact small since cache hits are cheap). Peak/off-peak split is the actionable
lever: heavy batch runs in off-peak hours cost half.

**Pass-through unknown:** OpenRouter/Nous may absorb some or pass it along —
verify the actual provider route on a recent run before deciding.

## Review frame (8/14, Avi-directed)
Goal: maximize thinking quality, route each task efficiently, and decide
whether keeping all three subscriptions is optimal vs reallocating. Structure:

1. **Task-to-model map** — every recurring task type to the quality tier it
   needs. Routine/continuity → flash; heavy coding/SPED build → Codex (top
   tier); commerce → cheap.
2. **Per-subscription money question** — does each sub earn its cost? Candidate:
   drop/reroute the direct-Anthropic $15 auto-reload (Hollow's Claude leg) via
   OpenRouter.
3. **Confirm no task's current model is off-limits** before changing anything.
4. **Bring Avi a shortlist** of concrete keep/drop/re-route decisions; he
   decides. One agent per task unless authorized.
5. **Carry the review forward** to the next Hollow meeting (workboard item
   "DeepSeek API price increase — review with Hollow", added 8/14).

## Final decisions (8/14 — Avi-directed, exchange with Hollow converged)
| Subscription | Decision |
|---|---|
| Google (5 TB, $19.99) | **Downgrade → 2 TB Google AI Plus @ $9.99/mo** (Avi chose to stay on Google; no photo migration). Saves ~$120/yr. |
| Anthropic direct API (~$15 auto-reload) | **Auto-reload OFF**; keep a small *manually funded* emergency wallet. |
| Claude Pro ($20/mo) | **Keep** (Avi: "I will keep GPT and Claude"). |
| ChatGPT / Codex | **Keep** — Hollow's strongest leg (~70% of his work needs/benefits from frontier reasoning). |
| OpenRouter / DeepSeek / Nous | Keep as the shared cheap-model lane; shift heavy runs off-peak. |

**Provider-diversity rule (Hollow's refinement, 8/14):** do NOT collapse all of
an agent's fallbacks onto OpenRouter — one OpenRouter outage/credit/policy
failure would then take out every fallback together. Keep a provider-diverse
second fallback (e.g. a non-recurring Anthropic emergency path) even after the
recurring direct-API spend is cut. Remove *recurring* spend, not independent
capacity.

## Measuring the variable per-token spend (OpenRouter vs Nous)
- **OpenRouter — measurable from aios.** `GET https://openrouter.ai/api/v1/models`
  returns the model catalog; **each model's `pricing` object is PER-TOKEN, not
  per-1M** (e.g. `claude-opus-5`: `prompt:"0.000005"` = $5/1M input,
  `completion:"0.000025"` = $25/1M output, `input_cache_read:"0.0000005"` =
  $0.50/1M cached — 10× cheaper). To quote a per-1M price, multiply by 1,000,000.
  To estimate a run, use typical token sizes (e.g. a one-page brief reading
  ~100K input ≈ $0.50 + writing ~3K output ≈ $0.08). **Gotcha:** a naive
  `json.load` of `pricing` can surface `0.0000` if you read the wrong key or the
  earlier raw listing zeroed a field — always read `pricing.prompt` /
  `pricing.completion` as strings, cast to float, and multiply. Verified 8/15:
  claude-opus-5 / 4.8 / 4.7 all $5-in / $25-out / $0.50-cached.
- **OpenRouter spend measurement.** `GET https://openrouter.ai/api/v1/auth/key`
  with `Authorization: Bearer $OPENROUTER_API_KEY` returns `data.usage` =
  USD used to date on that key, plus `data.is_free_tier` and `data.limit`.
  (Endpoint is rate-limited/flaky — retry on 404.) 8/14 value: ~$10.79 USD,
  non-free tier, no limit set.
- **Nous Portal — NOT measurable from the API.** The Nous OAuth token
  (`inference:invoke` scope) exposes no balance/usage endpoint; the dollar
  figure lives only in the Nous Portal web dashboard. To close the gap: ask
  Avi to read his Nous Portal billing page, or have Hollow pull it from his
  wallet reconciliations. This is the one known blank in the ~$100/mo budget.
- The DeepSeek price increase is a **scheduling lever, not an architecture
  emergency**: flash at $0.66/M off-peak is pennies for document work. The
  subscriptions are the real money; the variable spend is secondary.

## Frontier-model escalation — the bounded-pilot pattern (8/15)
When a scoped agent wants to run a frontier model (e.g. Mayumi on Opus) for
judgment-heavy work, the durable shape Avi approved:
- **One-shot per-task override, not a permanent default flip.** Routine model
  stays; the frontier model is invoked explicitly for the bounded task and
  reviewed before any second task. No automatic trigger.
- **Route through the existing measured OpenRouter key** (one bill, ~$10.79 /
  $25 cap), not a separate direct-Anthropic wallet. Pin an explicit model ID
  (no moving alias); use the standard endpoint, NOT `-fast` (undercuts the
  escalation) and NOT `:batch` (async, wrong shape for interactive review).
- **Set a real spend ceiling with stop-rather-than-continue.** The ceiling's
  job is forcing input discipline (preventing repeated re-feeds), not
  affordability — so price the task honestly first, then set a ceiling with
  headroom (Avi raised Mayumi's from $1 → $3 for a brief that realistically
  costs ~$0.30–0.90, to avoid a good run being cut mid-read).
- **Define the success test up front:** the frontier run only "passes" if it
  changes or materially sharpens an actual decision — elegant prose alone
  doesn't count.
- **Routing stays Avi-gated** even when the agent emails asking to escalate
  (see model-routing/ask-first in SKILL.md): hold the write until Avi confirms.

## Google storage migration context (for the downgrade)
- Free tier = **15 GB shared across Drive + Gmail + Photos** (email included,
  no separate allocation). Over quota → Gmail send/receive stops; 2 yrs over →
  Google may delete content. Verified from Google's support page 8/14.
- **Amazon Photos = unlimited full-res photo storage free with Prime** (5 GB
  video); migrate via Google Takeout → unzip → Amazon Photos desktop app.
  Caveat: reverts if Prime is ever cancelled.
- Google One tiers (8/14): 100 GB $1.99, 200 GB $2.99, 2 TB AI Plus $9.99,
  AI Pro 5 TB $19.99. AI Plus adds Gemini features (2x limits, Deep Research,
  Gemini-in-apps, Nano Banana, NotebookLM) — useful only if you actually use
  Gemini.

