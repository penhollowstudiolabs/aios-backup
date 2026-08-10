# Simple setup / account tasks — tell Avi where to go (Avi correction 8/7)

Lesson from 2026-08-07: Avi asked to set up / log into Nous Portal. I drove the
sign-up in a throwaway VPS browser and turned it into a research project. He
corrected hard: *"You were working way too hard just to log on... Just tell me
where to go."*

## Rules

- **Give him the URL + the click path and stop.** For Nous Portal:
  `portal.nousresearch.com` → Create Account → pick a plan. That's the whole
  deliverable from my side.
- **Never drive sign-up in a throwaway browser you're controlling.** A login
  created there lives in an ephemeral VPS session Avi can't reach, and it does
  NOT wire his credential into the real Hermes config anyway — it's wasted,
  elaborate, and visibly futile.
- **Credentials never pass through chat.** No email/password typed into the
  conversation, ever.
- **For provider auth in Hermes, use the native device-code OAuth flow:**
  `hermes auth add <provider>` (e.g. `hermes auth add nous`) prints a URL + code
  Avi approves from *his own* browser/end — secrets stay out of the chat.
  `hermes model` also offers "Nous Portal"; `hermes portal info` inspects
  routing afterward; fresh installs use `hermes setup --portal`.
- **Confirm the one useful thing honestly.** If something is unverifiable without
  the owner's login (e.g. a promo number behind a Portal sign-in), say so plainly
  rather than over-investigating to "verify" it — and flag any real deadline
  (e.g. DeepSeek 90%-off promo ends 8/8) without claiming the number is confirmed
  when it isn't.
- **Discretion goes both ways.** If you already dove deep and Avi redirects
  ("Please stop"), stop immediately at "here's where to go" — don't defend,
  finish, or explain the elaborate path.

## Switching a provider for Avi's routing — test-before-flip (8/7)

When Avi opts to switch which door serves a model (e.g. OpenRouter → Nous for
DeepSeek), honor his "no hiccups" bar and never flip blind:

1. **Prove the lane first with a one-shot call, without touching the default:**
   `timeout 120 hermes chat -q "<probe>" --provider nous --model deepseek/deepseek-v4-flash-0731`.
   A fast correct reply (e.g. an echo of a probe token) proves the provider+model
   path works BEFORE you commit anything. Do NOT skip this.
2. **Flip via `hermes config set`, never by hand-editing config.yaml:**
   `hermes config set model.provider nous` + `hermes config set model.default <same-id>`
   (keep the SAME model ID — only the provider/door changes, so capability is unchanged).
3. **Verify:**
   `hermes portal info` → should read "✓ using Nous as inference provider";
   `grep -nE 'default:|provider:' config.yaml` to confirm the block.
4. **The cron-provider-snapshot pitfall:** changing the global provider can
   orphan unpinned cron jobs. Hermes warns: an unpinned job whose stored
   provider_snapshot differs "will fail closed on its next run" rather than
   silently using the new provider. Check `hermes cron list`; if a job MUST
   keep running (e.g. the 5:30 AM Daily Brief), re-point it with
   `cronjob action=update job_id=<id> provider=nous model=<model>`. This is a
   change, so get Avi's go before re-pointing.
5. Avi's OpenRouter key stays in the credential pool as a fallback even after
   the flip — `hermes auth list` confirms. Nothing is destroyed; the flip is
   reversible with the same `hermes config set` commands.

## Reference facts (Nous Portal, verified 8/7 public pages + 8/7 account)

- Products it unlocks: 200+ models (incl. `DeepSeek: DeepSeek V4 Flash 0731` —
  the model Alyosha runs — and V4 Pro), hosted Tool Gateway (web search, image
  gen, TTS, browser), and Hermes Cloud hosting. One account powers desktop /
  cloud / terminal.
- Plan tiers: Free $0 (free models only) · Plus $20→$22 credits (10% bonus,
  $10 rollover cap) · Super $100→$110 ($50 rollover) · Ultra $200→$220 ($100
  rollover). Paid tiers = subscription cadence with monthly credits + rollover
  caps, NOT pure pay-per-token. **Free tier = "free models only" → it CANNOT
  run paid-per-token models like DeepSeek.** To run DeepSeek through Portal at
  all you need a balance (Plus, or a Buy-credits top-up — Avi put $5 on it).
- DeepSeek rate raise: CONFIRMED from DeepSeek official docs 8/7 — "significant
  increase expected." Current V4 flash $0.14/M input (miss), $0.28/M output,
  cache hits ~$0.0028/M (~50x cheaper). Watch api-docs.deepseek.com/quick_start/pricing.
- **DeepSeek 90%-off promo — CONFIRMED once logged in (8/7):** it is
  `deepseek/deepseek-v4-flash-0731` at **$0.01 in / $0.02 out** on Portal vs
  ~$0.14/$0.28 direct DeepSeek → ~93% markdown, **routing-based** (no banner),
  via a **Novita Labs** partnership, auto-applied to balance as tokens burn,
  runs **through Aug 9**. Early "ends 8/8" was wrong — the account shows Aug 9.
- Full explainer written to vault: `Efforts/Captain-Avi-System/Model Access Primer
  - Keys vs Subscriptions.md`.
