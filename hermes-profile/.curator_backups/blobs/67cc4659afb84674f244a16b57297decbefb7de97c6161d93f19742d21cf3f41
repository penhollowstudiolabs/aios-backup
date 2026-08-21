# Provider cost & routing monitoring — the "silent drain" failure (8/16)

Avi's marathon routing/cost audit revealed a recurring failure class. The goal
is "no open items": every provider lane measurable or funded, nothing silently
bleeding. Captured 8/16 from the Nous→OpenRouter outage.

## The failure mode (root cause of "it keeps happening")
- A provider is adopted for an original *intent* (e.g. "one Nous subscription,
  300+ models, one door") but the execution DRIFTS (it became an unmeasured
  $5 pay-as-you-go top-up, no subscription).
- One unmeasurable single point does TWO jobs (model + web tools) with nothing
  watching whether it's funded.
- When the pocket empties, calls fail AND the fallback blindly carries the load
  — so nothing appears broken, but the fallback is silently bleeding spend.

## The two hard rules from this session
1. **A fixed $X / a top-up price is NOT the same as observability.** Predictable
   ≠ visible. A number you wrote down once is not a check that runs.
2. **"We know it's unmeasurable" is NOT the finding — it's the thing to fix.**
   Logging a blank and moving on (the 8/15 review "priced Nous and called it
   complete") is exactly how it bites a week later. Close the loop with a
   monitoring step or accept it as an explicit, re-reviewed open item.

## Verified cost facts (8/16, first-hand)
- **Nous Portal paid tiers** (Avi via Gemini): Plus $20/mo→$22 credits incl,
  $10 rollover, 400RPM/4M TPM. Super $100→$110, Ultra $200→$220. Paid tiers =
  ~10% credit bonus toward inference AND bundled tool APIs (web search/image
  gen = Firecrawl) AND Hermes Cloud hosting.
- **Nous Toolbox couples model + web**: model inference AND web tools consume
  the same subscription allowance/auth path. One exhausted/revoked lane can
  degrade both reasoning and research. Independent web needs a separately
  funded Firecrawl key.
- **OpenRouter is NOT a Firecrawl/web-search provider** — you cannot fold
  "OpenRouter/Firecrawl" into one lane.
- **OpenRouter measurement endpoints**:
  - `GET /api/v1/credits` → `data.total_credits` + `data.total_usage` →
    remaining = difference. This is the real balance read.
  - `GET /api/v1/auth/key` → `data.usage`, `data.limit`, `data.is_free_tier`,
    `data.limit_remaining`. **`limit: None` = there is NO hard cap**, even if a
    vault note says "$25 cap". A written-down cap is not an enforced cap.
  - **There is NO public API to SET a key-level spend cap** — limits are set
    only in the OpenRouter dashboard (Keys → the key). Setting one is an Avi
    (dashboard) action, not an API call.
- Costs change fast; when quoting per-token, read `pricing.prompt` /
  `pricing.completion` as strings and cast (naive json may surface 0.0). See
  `references/agent-model-cost-review.md` for the per-1M math.

## Provider-diversity (Hollow's 8/14 rule, reinforced 8/16)
Nous is NOT categorically independent of OpenRouter — Nous routes some models
through OpenRouter. So counting Nous as the "diverse second lane" is wrong.
TRUE independence = a direct-vendor API lane (e.g. Anthropic) separate from the
provider that also routes the primary. Don't count Nous as the diversity leg.

## The detection watchdog that survived review
A 15-min "alert on primary-down" cron is considered EXCESSIVE — at night it
wakes nobody and it nags. The Daily Brief's `## System health` section (which
already caught the outage on its own) is the right alerting surface: providers
typically go down overnight, and the morning read is when action is possible.
Prefer folding a provider-health line into the daily brief over a buzzer cron.
Keep the tick watchdog pattern ONLY for genuinely time-critical lanes.

## Fallback reality-check
When the primary is empty, verify the FALLBACK is also funded before relying
on it. In 8/16 the OpenRouter fallback that was "carrying" the stack had itself
only ~$1.79 remaining — one step from total dead-end. Check remaining on the
fallback lane, not just the primary.