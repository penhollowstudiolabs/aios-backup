# Model routing & fallback — diagnosis and change (captured 8/09)

Incident: DeepSeek 503'd through the **Nous** provider route; Hermes silently
fell back to `google/gemini-2.5-flash-lite` (a lite-tier model) mid-conversation,
producing visibly degraded replies. Avi: "absolute shit"; "Alyosha should NEVER
default to such a shitty model."

## The failure signature in logs

In `~/.hermes/profiles/alyosha/logs/agent.log` (per-session):

```bash
# Fallback events for THIS session (fallback activated = quality cliff fired)
grep '<session_id>' agent.log | grep -iE 'fallback activated|gemini-2.5-flash-lite'

# Count of upstream capacity 503s on the primary route
grep '<session_id>' agent.log | grep -c '503'

# Last successful primary calls (proves primary is normally fine)
grep '<session_id>' agent.log | grep 'API call' | tail -3
```

The log line that names the cliff:
`Fallback activated: deepseek/deepseek-v4-flash-0731 → google/gemini-2.5-flash-lite (openrouter)`
with the prior line `Fallback to ... clearing primary credential pool
(pool_provider=nous) to prevent cross-provider contamination`.

## Why same-model-via-OpenRouter is the right fallback

- **Nous** = one upstream route to DeepSeek. When DeepSeek's API is
  capacity-starved, Nous 503s ("upstream capacity limits") and Hermes falls off
  to whatever's next in the chain.
- **OpenRouter** = aggregator. `deepseek/deepseek-v4-flash-0731` is served by
  multiple upstream hosts; OpenRouter fails over to another host serving the
  SAME model. So the fallback retries the same model on a different pipe
  instead of dropping quality.
- Verify the model exists on OpenRouter before configuring:
  `curl -s https://openrouter.ai/api/v1/models -H "Authorization: Bearer $OPENROUTER_API_KEY" | grep deepseek-v4-flash`

## Change commands (with Avi's explicit go-ahead ONLY)

```bash
hermes config set fallback_model.model deepseek/deepseek-v4-flash-0731
hermes config set fallback_model.provider openrouter
hermes fallback list   # verify: Primary nous + Fallback chain shows same model via openrouter
```

Notes:
- `hermes fallback add/remove` is an interactive picker — use `config set`
  for the two keys instead.
- `hermes config set fallback_model.*` prints a "not a recognized config key"
  warning (suggests `fallback_providers.*`). That warning is a FALSE POSITIVE:
  `hermes fallback list` reads the same keys and shows the chain correctly.
  Verify with `hermes fallback list`, not the warning text.
- `hermes config get fallback_model` shows the current fallback (model +
  provider) non-interactively.

## Rules that survive this incident

1. **Never set a lite-tier fallback for Alyosha.** Fallback must match the
   primary's quality tier (same model via another provider, or a comparable
   full model). gemini-2.5-flash-lite is a lite model — only acceptable for
   scoped cheap agents (Mayumi), never the continuity brain.
2. **Ask before inspecting or changing routing/fallback config.** Avi was
   explicit: "You need to ask me before configuring anything with model
   routing or fallbacks." Diagnose from logs freely; config reads/writes need
   his call.
3. Keep nous as primary when it's normally healthy; only flip primary to
   OpenRouter if the 503s become chronic (Avi's call).
4. A fresh session with a lean context sharpens replies regardless of
   provider — context bloat compounds capacity failures.
