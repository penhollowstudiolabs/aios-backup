# Inspecting model/provider routing in Avi's stack (verified Aug 2026)

Context: Avi's agents run across two VPS + laptop. This is the concrete, verified inspection play.

## What "the model" is composed of
Three layers, checked in order:
1. `config.yaml` → `model:` block (the *default*).
2. Per-chat / runtime override (the *active* model for a given conversation — can differ from the file).
3. `~/.hermes/profiles/<profile>/.env` → provider keys.

## Verified example (default `alyosha` profile)
`~/.hermes/profiles/alyosha/config.yaml`:
```yaml
model:
  default: anthropic/claude-sonnet-4-6
  provider: openrouter
```
`.env` had `OPENROUTER_API_KEY=sk-or-...` (plus a separate `ANTHROPIC_API_KEY=sk-ant-...`).
Hermes config show reported: `Model: {'default': 'anthropic/claude-sonnet-4-6', 'provider': 'openrouter'}`.

Key lesson from this run: even though `ANTHROPIC_API_KEY` is present in the env file, the *routing* was through OpenRouter — so switching this session to `deepseek/deepseek-v4-flash-0731` required NO new key. The DeepSeek model is served by OpenRouter using the one `OPENROUTER_API_KEY`.

## OpenClaw (laptop / other installs) — where the model is NOT
`openclaw.json` contains only gateway/auth/bind config:
```json
{ "gateway": { "mode": "local", "auth": {...}, "bind": "auto" }, "meta": {...} }
```
It has **no model/provider field**. OpenClaw's model comes from env vars or per-agent/session scope. To repoint an OpenClaw instance, inspect:
- environment variables (`OPENROUTER_API_KEY`, etc.)
- per-agent scoped config under the install's agents/ directory
Do NOT assume a central `openclaw.json` field exists.

## Reporting to Avi
- Run the real checks, paste the exact field values.
- State plainly: "only this session is on X; others keep their own config until changed."
- If he asks "did we configure DeepSeek without a key", the answer is: OpenRouter is the front door — one key, model ID swap, no new credentials.
