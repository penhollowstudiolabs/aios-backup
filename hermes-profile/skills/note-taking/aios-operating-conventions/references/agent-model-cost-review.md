# Agent-model cost review — routing, subscriptions, and the 8/2026 DeepSeek increase

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
- **OpenRouter — measurable from aios.** `GET https://openrouter.ai/api/v1/auth/key`
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

