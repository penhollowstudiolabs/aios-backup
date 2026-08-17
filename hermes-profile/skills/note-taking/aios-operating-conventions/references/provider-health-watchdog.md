# Provider-health / routing-wallet watchdog (8/16)

When an agent's PRIMARY provider is a pay-as-you-go pocket that is NOT
measurable from the API, it can silently run dry and dump every call onto the
fallback lane without anyone noticing for a full day.

## The failure we hit (8/16, Alyosha primary = Nous Portal)
- Nous Portal primary (`deepseek-v4-flash-0731` via Nous) is **pay-as-you-go**,
  and exposes **no balance/usage endpoint** from the API (`inference:invoke`
  OAuth scope). The dollar figure lives only in the web dashboard.
- The $5 top-up drained overnight. Every Nous call began returning
  `404 ... requires available credits`, so the session **silently ran on the
  OpenRouter fallback** for hours/days — inside the $25/mo cap but burning
  spend without the intended primary. Web tools (Firecrawl via Nous) also died
  with the same empty pocket.
- Discovery was late because the consolidation session had **"resolved"** Nous
  by writing "$5 top-up, ~$1.82/d" and closing with "no open items" — treating
  the *known unmeasurable blank* as a priced finding instead of as the thing
  to actually monitor.

## Lesson (durable)
- **A provider that cannot be measured from the API is not "priced" when you
  write a number on it — it is UNMONITORED.** Poetry along a number on an
  unmeasurable pocket makes the blank worse, not resolved. Add a check that
  the primary actually responds and is funded, in the same pass.
- **A hot fallback is not health."** If primary X dies and everything lands on
  fallback Y, the agent still "works" (feels fine) while bleeding Y's spend.
  Always confirm which provider served the last call, not just that a call
  succeeded.
- **Web tools riding the same pocket."** Managed web tools (Firecrawl via
  Nous) share the same credit pool. When the primary dies, web tools die with
  it — and web_search/web_extract errors ("SET FIRECRAWL_API_KEY ... or our
  Nous Portal has no usable paid credits") are a downstream symptom, not a
  separate web-tool bug.

## The fix we built (stability first)
A provider-health watchdog script that:
- greps `~/.hermes/profiles/alyosha/logs/errors.log` for the primary-failure
  signature (`"requires available credits"`),
- fires **once** per DOWN state change (never nagging while still down),
  then one RECOVERED message when the primary comes back,
- is silent when healthy, so it is zero-cost and zero-spam.

The script lives at the canonical path for a copy: **Astral_script**
`scripts/provider-health-watchdog` (see the skill's scripts/ dir) and the
live cron on aios is the `provider-health-watchdog` job (every 15 min,
no_agent, deliver=origin). It is located under this skill so a refreshed box
can re-install the same guard.

## Verification (8/16)
- Manual first run correctly reported: "Nous primary DOWN (last failure
  2026-08-16 15:08:47 UTC) — running on OpenRouter fallback. 109 failures."
- Second run with the same state was silent (de-duplicated). Good.