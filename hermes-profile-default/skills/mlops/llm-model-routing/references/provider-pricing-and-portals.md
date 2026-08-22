# Provider pricing sources, portals, and the economics of cheap routing

Session-grounded notes (2026-08-07, Avi's stack). Keep the *methods* here durable; re-verify the
specific numbers before acting — pricing moves.

## Nous Portal — a real provider door (house product of Nous, the Hermes makers)
- Sign-in / OAuth: `hermes setup --portal` — one OAuth covers the model catalog + Tool Gateway
  (web search, image gen, TTS, browser).
- Portals (`portal.nousresearch.com`) is behind a Vercel security checkpoint for unauthenticated
  browsers — expect a gate; model-list is public but **per-model pricing is behind sign-in**.
- Catalog carries 200+ models incl. `DeepSeek: DeepSeek V4 Flash 0731` (the exact model Avi's
  Alyosha ran via OpenRouter) and V4 Pro.
- Plan tiers (as of 2026-08-07): Free $0 (free models only) / Plus $20→$22 credits, $10 rollover /
  Super $100→$110, $50 rollover / Ultra $200→$220, $100 rollover. All credits monthly meter,
  not pure pay-per-token like a direct API.
- Decision posture for a cost-conscious single operator: opening a Free-tier Portal account is
  cheap "seize-to-look" (get inside to read the real promo price before it closes); do NOT
  migrate routing to Portal on the strength of an *unverified* promo, because a Portal sub is a
  monthly-credit cadence, not pay-as-you-go.

## Checking DeepSeek pricing (curl gotcha)
The DeepSeek pricing page 302-redirects and needs a browser-ish UA; without `-L` and a UA it
returns a redirect blob, not prices.
```bash
curl -sL https://api-docs.deepseek.com/quick_start/pricing \
  -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
  | sed -e 's/<[^>]*>//g' | grep -viE '^\s*$'
```
Structured pricing (per 1M tokens) is on the page. DeepSeek docs carry a banner that they plan a
"significant" future price increase — recheck this page when recalibrating.

## The cache-hit economics (why long sessions get cheap)
DeepSeek V4 flash: cache-MISS input ~$0.14/M, cache-HIT input ~$0.0028/M — roughly a **50x
spread**. Long, repeated sessions get cheap *because* of prompt caching. So:
- Cost discipline favors keeping long sessions (caching) over spawn-new-every-turn.
- Don't judge cost by price-per-token alone; judge by **cost per successful task** (a cheap
  model that forces retries can cost more than a pricier one that gets it right first time).

## The one-active-surface rule (cost lever Avi's stack actually uses)
Desktop / CLI / Telegram are **separate Hermes sessions = separate contexts**. Running the same
task on two surfaces in parallel duplicates context and tokens. Rule:
- Desktop = deep collaboration / review (richest, per-session model switch on dashboard).
- Telegram = mobile async check-in (highest context-bloat risk; long sessions balloon; saw
  ~127k tokens → 1.5–4 min responses. Reset/compact to clear).
- CLI = leanest, scriptable automation.
- "One active surface per task." Switching mid-task = paying for the context twice.

## Keys vs subscriptions vs portals (one-line map for explaining to Avi)
- Subscription = flat $/mo, only usable in the vendor's own app. Agents CANNOT ride it.
- API key = pay-per-token, is what agents run on (the actual fuel).
- Portal (OpenRouter, Nous Portal) = aggregator/reseller layer; one key/sub unlocks many models,
  sometimes promo rates. Legit, not a "hack."
- Rationed Anthropic wallet (`sk-ant...`) and OpenRouter key (`sk-or-v1...`) are the agent fuel;
  killing an API wallet does NOT touch a claude.ai/ChatGPT subscription, and vice versa.
