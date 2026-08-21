# OpenClaw (Hollow) model CLI — verified commands + don't-guess rule

Verified 8/14 while stabilizing Hollow after the direct-Anthropic credits ran
dry and his model chain went quiet. Use these exact commands when walking Avi
(or Hollow) through a model change on the laptop — do NOT invent names.

## Why this exists

I guessed `openclaw models get` / `openclaw models list` while Avi sat at the
laptop terminal, and he called it: *"Something tells me you don't know claw
commands."* The fix is the real command set (below) and the rule: **never
fabricate a CLI name when the human operator is about to type it.** If you are
not certain of a command, ask the operator to run `openclaw --help` / `openclaw
models --help` first and work from the ACTUAL output — or verify against
https://docs.openclaw.ai before proposing anything.

## Verified command set (from OpenClaw docs + live use)

### Inspect
```powershell
openclaw status                                  # gateway + runtime health
openclaw models status                           # default/primary + configured fallbacks in one view
openclaw models status --json                    # machine-readable
openclaw models list                             # configured models + auth status
openclaw models auth list                        # which providers have keys/OAuth
openclaw models fallbacks list                   # current fallback chain
```

### Change
```powershell
openclaw models set <provider/model>             # sets primary; writes agents.defaults.model.primary
openclaw models fallbacks clear                  # drop the whole fallback chain
openclaw models fallbacks add <provider/model>   # rebuild a fallback leg
openclaw gateway restart                         # apply after model/config changes
```

### In-chat (fastest live switch, use first in a time-critical outage)
In Hollow's Telegram, the running gateway can override the CLI config write
(`openclaw models set` "took" but the gateway still showed the old model after
restart). The reliable live switch is the in-chat slash command:
```
/model <provider/model>
/model status
```

### Verified model refs in this operation (8/14)
- DeepSeek via OpenRouter: `openrouter/deepseek/deepseek-v4-pro` (Hollow primary when stable)
- DeepSeek flash: `openrouter/deepseek/deepseek-v4-flash-0731`
- GPT via Codex OAuth: `openai/gpt-5.6-sol`

## The 8/14 stabilization sequence (what worked)

1. Confirm the fault is model/billing, not the channel: the in-chat `/model
   openrouter/deepseek/deepseek-v4-pro` attempt returned a **billing error** from
   OpenRouter — i.e. the switch itself hit a no-credits wall, proving the chain
   pointed at accounts with no balance (direct Anthropic dead, and OpenRouter
   key for Hollow also bad). That told us to try the one funded path: Codex
   (`openai/gpt-5.6-sol`), which bills the healthy ChatGPT sub.
2. Use `/model` in-chat first (live), then `openclaw models set` + `fallbacks
   clear/add` + `gateway restart` to make it durable.
3. Keep the whole chain on one funded provider when time-critical; defer
   re-linking/deferred work (Codex binding repair) for later.

## Pitfalls
- **Don't collapse every fallback onto one provider** (Hollow's 8/14 point): one
  OpenRouter outage then takes out DeepSeek AND Claude together. Keep provider
  diversity — e.g. auto-reload OFF on direct Anthropic but a small manually
  funded emergency wallet as a second-provider path.
- **`openclaw models set` writes config; the running gateway may override it.**
  The in-chat `/model` is the authoritative live switch.
- **No SSH on `avi-laptop`** — you cannot run these from aios. Route a message
  via the AgentMail lane and walk the human operator through them manually.
