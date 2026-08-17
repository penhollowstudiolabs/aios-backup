# Nous Portal plans & the "use a working route" lesson (8/16)

## Nous Portal paid tiers (verified via Gemini, 8/16)
Nous Research Portal tiers — model access + Hermes Cloud agent hosting + the Tool Gateway:

| Tier | Price | Monthly credits incl. | Rollover cap | Rate limits |
|---|---|---|---|---|
| Free | $0/mo | $0 (free-catalog only) | — | 50 RPM / 500K TPM |
| **Plus** | **$20/mo** | **$22** | $10 | 400 RPM / 4M TPM |
| Super | $100/mo | $110 | $50 | 800 RPM / 8M TPM |
| Ultra | $200/mo | $220 | $100 | 1,600 RPM / 16M TPM |

Paid tiers give a **~10% credit bonus** on top of the subscription fee, applied toward
inference on paid models, **bundled tool APIs** (web search, image generation), and
Hermes Cloud instance hosting.

**Why this matters for routing:** the original 8/4 intent — "one Nous Research
subscription → 300+ models, one door" — is exactly what **Plus ($20)** buys, and its
$22 of credits feed BOTH the model AND the managed web tools in one predictable pot.
The drift that caused the 8/16 drain was running Nous as a **$5 pay-as-you-go
top-up with no subscription** and no API-usage endpoint. If Avi values "one door,"
Plus restores it: Nous Plus primary (+ $22 web-included) + OpenRouter measurable
$25-cap fallback (~$95/mo total, inside his ~$100 mental budget).

**Weighing: Plus ($20, ~$22 usable, web included, fixed) vs OpenRouter primary
($10.79 measured, $25 cap).** Same tier. The deciding factor is whether Avi still
wants the original "one Nous door" or prefers the provider he already measures.

## The "use a working route" lesson (Avi correction, 8/16)
When Avi needs a fact (e.g. the Nous subscription price) and it turns out I/we
should easily have gotten it: I burned tool calls failing (portal rate-limited,
docs JS-rendered, web tools down on the same empty pocket) and dumped a long
"I can't verify" analysis. Avi pulled the full pricing table himself in seconds
via **Gemini flash** and asked twice: *"I'm not sure why neither you or Hollow could
have done this."* I had a **working Gemini-via-OpenRouter route the whole time**
(`auxiliary.vision` = `google/gemini-2.5-flash` via OpenRouter) — it was not gated by
the dead Nous pocket.

Rule: **when one lane/provider/tool is blocked, reach for a DIFFERENT working route
before concluding "can't verify."** We hold multiple providers (Nous, OpenRouter,
Gemini-flash-vision, plus direct API keys). A dead primary pocket does NOT mean the
world is unverifiable. Check what alternative route is actually authorized and live,
and use it — especially cheap read-like lookups (a model call, an oembed endpoint,
a curl to a static page) that don't need the dead tool at all.

Combine with the "be TIGHT when you can't verify basics" SKILL.md section: state
the gap in one line, use a working alternate to close it if one exists, and only
then hand an irreducibly unverifiable fact to Avi.