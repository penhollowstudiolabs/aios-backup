# Provider cost-reliability audit — classification & durable lessons (8/16)

Class-level pattern: when a "cost/routing" incident happens (a paid model lane
goes quiet because its wallet drained silently and everything fell back onto
another bill), the fix is a **classification**, not a patch. This file is the
reusable audit frame + the specific Nous/OpenRouter facts learned 8/16.

## The structural classification (what to look for)
Every model/web-tool lane falls into one of two failure shapes:

1. **Measurable, single-purpose, capped** — a wallet you can read (`GET
   /api/v1/auth/key` → `usage`), doing ONE job, with a REAL enforced cap.
   On failure this is clear and alertable.
2. **Unmeasured, multi-purpose, single-point-of-failure** — a pocket that funds
   BOTH the model AND the managed web tools, with no API-readable balance.
   On failure this fails silently AND takes down two capabilities at once.

`Nous Portal` was adopted 8/4 as "one Nous subscription, 300+ models, one door"
but the EXECUTION drifted to an unmeasured $5 top-up feeding both model + web
tools. That drift — intent vs executed shape — is the recurring-cause to catch.

## Durable provider facts (verified 8/16)

- **Nous Portal paid tiers** (model access + Hermes Cloud + Tool Gateway):
  - Free $0 (free-catalog only), Plus **$20/mo → $22 credits**, $10 rollover,
    400 RPM / 4M TPM; Super $100/mo → $110, $50 rollover, 800/8M; Ultra
    $200/mo → $220, $100 rollover, 1600/16M. Paid tiers give ~10% credit bonus
    usable on inference, bundled tool APIs (web search/image-gen), and Hermes
    Cloud hosting.
- **Nous Tool Gateway natively routes web via Firecrawl** — a separate Firecrawl
  key is NOT needed when web rides the Portal Tool Gateway. But model + web
  share the same allowance = a coupling. OpenRouter is NOT a web/Firecrawl
  provider, so a model-on-OpenRouter lane still needs its own web backend.
- **Nous is NOT categorically independent of OpenRouter**: Nous routes some
  models through OpenRouter/secondary providers, and a model's backend can
  change. Count the provider-diversity legs carefully — "Nous + OpenRouter" is
  not guaranteed true diversity. Direct Anthropic API is the genuinely
  independent emergency lane (auto-reload OFF, manual wallet).

## The "cap" gotcha — a written note is not an enforced limit

We logged "$25/mo cap on OpenRouter" as truth, but `GET /auth/key` returned
`limit: None, limit_remaining: None` — the cap existed only in a vault note,
NOT at the key level. OpenRouter silently bled $10.79 → $18.37 on the
dead-Nous fallback. **Verify a cap is real at the provider/key level before
relying on it**; a documented figure is not protection.

## Detection: match cadence to when failures are actually acted on

A 15-min provider-health watchdog is over-building: most failures happen
overnight when nobody reads a ping, so a buzzer just nags. The Daily Brief's
existing one-line system-health section already caught today's outage. Put a
provider-health check in the brief (morning surface) rather than a high-frequency
cron. Silent-when-healthy + single alert on state change is fine ONLY if someone
is actually watching at that hour.

## Pitfall — verify facts through a WORKING lane when a tool is down

When the primary web lane is down (empty pocket), don't infer or stay silent.
Use a WORKING auxiliary route — Gemini via OpenRouter (the vision/aux lane is a
real model call), or direct `curl` to a public endpoint (`youtube.com/oembed`,
YouTube `ytInitialPlayerResponse`, a provider's public pricing/discovery API).
8/16: Avi looked up the Nous price via Gemini while I and Hollow assumed it was
unreachable because the web tool was down. The auxiliary model IS reachable when
the main web lane isn't — use it to close facts instead of leaving open items.