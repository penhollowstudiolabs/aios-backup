# Agent cost-review closure — 8/15 (Nous resolved, subscriptions finalized)

Durable facts that closed the model/subscription review begun 8/14. Complements
`agent-model-cost-review.md`. Read both before discussing Avi's model stack.

## Nous Portal — NO subscription, pay-as-you-go (RESOLVED 8/15)
- Avi confirmed via the Nous Portal dashboard: **no active Nous subscription**.
  He is on **pay-as-you-go top-up credits** — a $5 top-up, ~$1.82/30d spend,
  ~$3.18 balance remaining.
- The "$20/mo Plus" shown on the plans grid is the **UI-selected/recommended
  option, NOT a billing plan**. Distinguish a highlighted plan from an ACTIVE
  subscription: an active plan shows a cancel/manage path and subscription
  credits > 0; a non-active one only shows a "Subscribe" button.
- **Mental-model correction:** Nous Portal is NOT inherently a "subscription
  cadence (monthly credit meter + rollover cap)." That describes the *plans*;
  an account can run unsubscribed on top-ups. Check the dashboard before
  assuming which mode a given account is in.
- Net: Nous is the cheapest line in the stack (~$1.82/30d), not a budget driver.

## Google — downgrade EXECUTED (8/15)
- Avi stayed on Google (chose NOT to migrate photos to Amazon/Prime).
- **5 TB AI Pro ($19.99/mo) → 2 TB Google AI Plus ($9.99/mo)**, effective
  **Aug 17, 2026**. 269 GB used sits fine in 2 TB.
- AI Plus at $9.99 is the same price as the old non-AI 2 TB plan; the Gemini
  AI bundle is filler for Avi (he uses Gemini least) but the storage size is
  what he needs.
- Google One plan-change UI: use the Google One app or `one.google.com/plans`;
  "Downgrade" button appears because it's a step down. Confirm the plan is
  2 TB + $9.99 before committing (avoid 400 GB $4.99 or 5 TB Pro $19.99).

## Anthropic — auto-reload was ALREADY OFF (correction 8/15)
- Avi confirmed: **auto-reload was already off** — there was never an active
  recurring Anthropic top-up. The vault's "$15 auto-reload (set 8/10)" note
  was **wrong** (that number was the minimum top-up Google requires, misread).
- Current state: **~$19.22 balance, no auto-reload, key kept** = the intended
  "small manual emergency wallet, replenish only on incident" shape. No action
  needed — it's already in the desired state.

## Honcho key — identified and retired (8/15)
- The "unexplained OpenRouter usage" Hollow flagged was **Honcho's own\n  memory pipeline**: an OpenRouter key named **`honcho-memory-v1`** calling\n  OpenAI embeddings + GPT-5.6 "Deep Reasoning." Not rogue usage.\n- **Activity date clarified (Hollow, 8/15): Aug 4 migration-era**, not Aug 8\n  (Aug 8 was when it was *noticed*; the usage itself was migration-era).\n- It's an **OpenRouter key, not a Honcho-dashboard key** — revoked in\n  OpenRouter (API Keys). **Key DELETED 8/15.**\n- Honcho is dormant on aios (HONCHO_API_KEY commented in env, no\n  `~/.honcho/config.json`, no containers). Avi will re-enable Honcho for\n  Alyosha later via a **fresh** key/reinstall (retire the old VPS1 stack),\n  separate from any Hollow Honcho decision.\n- This resolved the OpenRouter key-ownership reconciliation item.\n\n## OpenRouter cost — measured + capped
- `GET https://openrouter.ai/api/v1/auth/key` (Bearer key) → `data.usage` =\n  USD used to date. Endpoint is rate-limited/flaky — retry on 404.\n- 8/15 value: **~$10.79 USD**, non-free tier. This is the one confirmed\n  OpenRouter figure; no separate VPS1/Hollow number to add (don't\n  double-count). Ownership reconciled by the Honcho finding.\n- **Cap SET 8/15:** OpenRouter workspaces = per-key **Credit limit** + **Reset\n  limit** (choose monthly, resets 1st). Set **$25/mo monthly** on the\n  `hermes-vps-fallback` workspace key. Workspaces = one shared bill, keys\n  scoped per-workspace. See `openrouter-workspaces-and-limits.md`.
