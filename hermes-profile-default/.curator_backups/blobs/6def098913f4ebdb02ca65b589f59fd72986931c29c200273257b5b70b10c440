# Canonical current record — fleet model routing (2026-09-03)

Avi's durable expectation: a shared operational map has **one canonical file kept current — he should never have to search** across scattered notes for current state. This reference captures how that was applied when the fleet model-routing record was restructured.

## Why this happened
Routing state for the fleet was spread across 5+ files: a tracking table, a CAPTURE_LOG snapshot, two cost audits, and per-agent self-orientations. The tracking table's header still read "routing as of 2026-08-05" — stale baseline presented as the record, so drift hid. Avi: "we should always have our model routing plan documented canonically and current so that I don't have to go search for it."

## What a correct record looks like
- **Header names the file as THE single source of truth**, plus owner and review cadence.
- **Current state table leads**; historical/context sections follow and are labeled historical.
- **Every row stamped LIVE <date> or DOC <date>.** LIVE = confirmed against the live config/tool that date; DOC = documented but NOT re-confirmed — never presented as current.
- **Same-work-session stamping:** every routing change updates the table the session it's made.
- **Cross-machine honesty:** a row the current box cannot reach (e.g. Hollow's laptop, Mayumi's VPS1) is DOC and assigned to the owning agent to self-confirm — never fabricated as LIVE.
- **Live-vs-doc conflicts are surfaced**, not silently resolved either way.

## Canonical location
`Efforts/Captain-Avi-System/Model-Token-Usage-Tracking.md` (Alyosha-owned). Restructured routing-first: canonical table → conflict/open items → wallet/limits (historical cost context only) → usage log → recalibration checklist → incidents.

## Real drift it caught (the reason to keep current records)
Documented + remembered: Alyosha's fallback = same model `deepseek-v4-flash-0731` via OpenRouter, active since 8/9. Live reality (2026-09-03): the running `default` config's `fallback_model:` block is **commented out** and `hermes fallback list` returns "No fallback providers configured." The fallback lived only on the old `profiles/alyosha` reference config; the clean-default rebuild did not carry it across. Conclusion: after any clean rebuild / profile cutover, re-verify the fallback chain live (`hermes fallback list`, inspect `fallback_model:`) — do not trust pre-rebuild docs/memory. Re-enabling is a routing-config change → Avi sign-off required.

## Identity resolution before reporting routing
A machine can hold several Hermes configs that disagree (root `default` via `HERMES_HOME=~/.hermes` vs a named `~/.hermes/profiles/<name>/config.yaml` kept as pre-rebuild reference). Establish which actually runs before reporting:
- `echo $HERMES_HOME` + `hermes config path`
- `ps aux | grep hermes` — which gateway processes, under which `--profile`
- then read that profile's `model:` / `fallback_model:` and run `hermes fallback list`
Do not infer live identity from a profile label or CLI `--profile`.
