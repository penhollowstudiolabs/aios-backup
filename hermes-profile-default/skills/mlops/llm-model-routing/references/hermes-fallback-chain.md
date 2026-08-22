# Hermes fallback chain: configure, diagnose, avoid the quality cliff

## The 2026-08-09 incident (why this file exists)
- Avi's Telegram chat quality collapsed mid-morning. Root cause: DeepSeek via the **nous** provider returned 16× HTTP 503 "upstream capacity limits" in one session; Hermes then **silently fell back to `google/gemini-2.5-flash-lite`** (the configured fallback) — a lite-tier model. Replies degraded to garbage with no visible error.
- The fallback had sat in config since ~Aug 5 and was listed in the Aug 7 routing review without ever being scrutinized. Lesson: **when reviewing routing, review the fallback chain with the same quality bar as the primary.** A lite-tier fallback is a silent quality cliff.

## Inspect
```bash
hermes fallback list               # primary + ordered fallback chain
hermes config get fallback_model   # model: ... / provider: ...
hermes status                      # model + provider summary
```

## Diagnose silent fallback in logs
```bash
cd ~/.hermes/profiles/<profile>/logs
# fallback activations for a session
grep '<session_id>' agent.log | grep -iE 'fallback activated|gemini-2.5-flash-lite'
# 503s on the primary provider
grep '<session_id>' agent.log | grep -c '503'
# which model actually answered (API call lines)
grep 'API call' agent.log | tail
```
Key log line:
`Fallback activated: deepseek/deepseek-v4-flash-0731 → google/gemini-2.5-flash-lite (openrouter)`

## Change the fallback (non-interactive)
`hermes fallback add|remove` are **interactive pickers** (no flags) — unusable in scripts. Set the config keys directly:
```bash
hermes config set fallback_model.model deepseek/deepseek-v4-flash-0731
hermes config set fallback_model.provider openrouter
```
**Gotcha:** the CLI prints `⚠ 'fallback_model.model' is not a recognized config key — Did you mean: fallback_providers.model`. This is a **false positive**. `fallback_providers` is a separate key (returns `[]`); `hermes fallback list` reads `fallback_model.*` and shows the new chain. Verify with `hermes fallback list` — do not chase the warning.

## The rules (Avi, explicit, 2026-08-09)
1. **Ask before touching routing/fallback config.** Even read-only probing of routing config drew a correction: *"You need to ask me before configuring anything with model routing or fallbacks."* State the plan, get the go, then change.
2. **Fallback must match the primary quality tier.** *"Alyosha should NEVER default to such a shitty model."* Never a lite-tier model as the default fallback for a main agent.
3. **Preferred fallback for a provider-capacity problem: the SAME model via a different provider.** Same weights, different pipe. Nous = one route to DeepSeek; OpenRouter serves the same model ID from multiple upstream hosts, so a saturated upstream fails over *within the model* instead of dropping quality. (Verified: `deepseek/deepseek-v4-flash-0731` is on OpenRouter.)
4. **Provider capacity ≠ model quality.** 503 "upstream capacity limits" on the nous route means the provider's route to the model is saturated — not that the model is bad. Fix the pipe, don't blame the model.

## Timeline of the fix (2026-08-09)
- Before: primary `deepseek/deepseek-v4-flash-0731` (nous), fallback `google/gemini-2.5-flash-lite` (openrouter).
- After: fallback → `deepseek/deepseek-v4-flash-0731` (openrouter). Verified via `hermes fallback list` (chain shows 1 entry = same model via openrouter).
