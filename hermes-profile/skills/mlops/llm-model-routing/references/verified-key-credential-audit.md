# Verifying which API key is actually wired — and reconciling credits views

Verified on Avi's two-VPS Anthropic stack (2026-08-05). Use when a user hands you
a screenshot/JSON of their provider account and you need to know which real key is
in play and whether it's funded.

## 1. Match the config-wired key to the account key list (don't trust memory)

Your `.env` masking shows only `sk-ant...aAAA` — useless for disambiguation. The
account JSON/screenshot carries partial keys like `claude-code-vps ...aAAA` /
`mayumi-key ...AQAA`. Match on the **last 4 chars of the API-key body**, which the
partials share:

```bash
# signature of each wired key: first6...last4
grep -E '^ANTHROPIC_API_KEY=' <profile>/.env | cut -d= -f2 \
  | sed -E 's/(^.{6})[0-9a-zA-Z]+(.{4})$/\1...\2/'
```

Key parts to compare:
- `claude-code-vps` partial `***...aAAA`  → in every active config
- `mayumi-key`         partial `***...AQAA` → present at ACCOUNT level but NOT in
  any `.env` → parked/unused. A key existing on the account does NOT mean it's wired.

## 2. Prove the key works with a real (tiny) call

```bash
KEY=$(grep -E '^ANTHROPIC_API_KEY=' <profile>/.env | cut -d= -f2)
curl -s -m 30 https://api.anthropic.com/v1/messages \
  -H "x-api-key: $KEY" -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"<a real model id>","max_tokens":10,"messages":[{"role":"user","content":"Say OK"}]}'
```
`content` in the response = key authenticates. Use the cheapest current Sonnet id.

## 3. Credits/balance: NO public REST endpoint exists

Anthropic returns 404 for `/v1/organizations`, `/v1/organizations/usage/credits`,
`/v1/usage/organization` etc. against an API key. **Credits/funding live in the
web console only** — the only authoritative view is the user's logged-in console
screenshot or the website. Do not claim a balance from the API; state that the
balance is console-only.

## 4. JSON vs screenshot numbers differ = two different wallets, both real

A JSON export and a screenshots page can disagree on auto-reload, spend, cap and
balance (observed: API-console view `$5.01 / auto-reload ON / $200 cap / resets Aug 31`
vs Claude plan/consumer view `$43.25 / auto-reload OFF / $100 cap / resets Sep 1 +
$8.04 promo to Sep 19`). These are the **API workspace** and the **Claude plan**
wallets under one login — not a conflict. When reconciling, say which view each
number came from instead of picking one as "the truth".

## 5. Reconcile model IDs against what the account actually offers

Routing may pin an older id (e.g. `claude-sonnet-4-6`) while the account now lists
newer models (Sonnet 5, Opus 5, Fable 5). Flag the drift rather than leaving stale
pins; confirm current ids before recommending a default.
