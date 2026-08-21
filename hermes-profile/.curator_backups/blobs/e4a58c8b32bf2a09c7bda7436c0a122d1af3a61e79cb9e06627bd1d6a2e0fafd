# Anthropic Console — two different money controls (don't confuse them)

The Anthropic console has **two separate money settings** that look similar and
were confused on 8/10 (the $200K "spend limit" got misread as a $200/mo
"auto-reload"). Distinguish them every time:

| Control | What it is | Where | Touches the card? |
|---------|-----------|-------|-------------------|
| **Monthly spend limit** | A **usage ceiling** — the max the org may spend on API calls in a period. Default is **$200,000**. | Settings → Billing → Spend limits | NO. It just stops usage at the cap. |
| **Auto-reload** | A **payment top-up** — when the credit balance runs low, it refills the wallet. **Minimum is $15** (you cannot set it lower; $10 is rejected). | Settings → Billing (or "Add funds" from dashboard) | YES — this is the amount charged. |

## Facts learned 8/10 (Avi's account, claude-code-vps wallet)

- Balance was ~$14.36; monthly spend ~$2.72 (0% of the $200K ceiling).
- Auto-reload set to **$15** (the minimum requirement — Avi tried $10, not allowed).
- There was **never** a $200 auto-reload; the "$200" figure was the $200K spend
  limit being misread. The tracking doc now records this correction so the
  myth doesn't resurface.
- Claude.ai **Pro** plan is **$20/mo** (corrected 8/9; was misrecorded as $100).
  Promo credit expires **Sep 19** — decide use-or-lapse before then.

## Reading the console

- Dashboard cards: "Organization credits" (balance + auto-reload status),
  "Spend this month" (spend vs ceiling, reset date), "Prompt caching", "Token volume".
- When Avi screenshots the console, read the **spend-limit card** as a ceiling
  (no action needed, harmless) and look for the **auto-reload status line**
  (green "Auto-reload is on") under credits — that is the payment setting.
- Recalibration cadence per the vault tracker: monthly, after Aug 31 / Sep 1
  wallet resets.

## Pitfall

Never report "auto-reload is $X" from the spend-limit page — the two are
independent. If a number looks huge ($200K) it is a ceiling, not a charge.
