# OpenRouter Workspaces & per-key credit limits (8/2026)

## When to use
Setting a spending cap on OpenRouter, or configuring separate environments for agents/projects. OpenRouter rolled out **Workspaces** (announced 4/2026), which changed where key config and limits live.

## Workspaces model
- Each workspace has **independent** API keys, guardrails, BYOK, routing defaults, presets, plugins, observability, members.
- **One bill across all workspaces** — credits/billing is account-level, shared. A credit limit on a key caps THAT key/workspace's spend; it does NOT cap the overall account balance.
- Existing keys live in a **Default workspace** unless you created a new one. On Avi's account there is a `hermes-vps-fallback` workspace (his fallback key).
- Account-level settings (activity, billing, org/members, management keys, privacy) are shared across all workspaces. Account-level data policies are the *ceiling*; workspaces can only be more restrictive.

## Per-key credit limit (the cap)
The dashboard key page has a **Credit limit** field and a **Reset limit** dropdown:
- **Credit limit** — once the key's spend reaches this, the key stops working (HTTP 402). Leave blank for unlimited. This is the `limit` / `limit_remaining` on the key.
- **Reset limit** — `daily` (midnight UTC) / `weekly` (Monday) / `monthly` (1st). Choose **monthly** for a clean monthly budget window matching Avi's $/mo frame.
- Setting a per-key cap is the bounded, right move. It does NOT cover other keys/workspaces — set per-key limits on each (Mayumi/VPS1 key, management keys) if you want total coverage.

## Measuring spend (real number, from the VPS)
```python
# OpenRouter key from profile .env -> data.usage = total USD spent
GET https://openrouter.ai/api/v1/auth/key   (Authorization: Bearer <key>)
```
- On 8/14 this read **$10.79** usage on the `hermes-vps-fallback` key (non-free tier, no limit set). The key page also shows its own 30-day spend graph (the fallback key was only $0.04/30d in this review).
- Per-key, per-window spend is available via `/api/v1/key` → `usage_daily/weekly/monthly`.

## Honcho key (8/14 finding)
The mysterious "unexplained usage" was an **OpenRouter key named `honcho-memory-v1`** — Honcho's memory pipeline calls OpenAI embeddings + GPT-5.6 through it (App: "Honcho Deep Reasoning"). Revoke it **in OpenRouter → API Keys**, not in app.honcho.dev. Retiring it resolves the ownership-reconciliation item: that key was Honcho's, its usage was legitimate, and removing it gives a clean slate for a fresh Honcho reinstall later.

## Pitfalls
- A credit limit on one key ≠ a hard cap on the whole account. If the goal is a total monthly ceiling, cap every key.
- The dashboard URL/path differs from older docs; current UI is `openrouter.ai/workspaces/<name>/keys`. Avi navigates here himself (he's the account owner) — guide by what he screenshots, don't hardcode a path you haven't confirmed.
- "Limit" appears in two senses: **credit limit** (spend, → 402) vs **rate limit** (requests, → 429). Don't confuse them when reading docs or the dashboard.
