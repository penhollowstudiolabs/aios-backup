#!/bin/bash
cd /root/.hermes
export $(grep AGENTMAIL_API_KEY .env | xargs)
python3 - << 'PYEOF'
import urllib.request, json, os
key=os.environ.get('AGENTMAIL_API_KEY','')
H={'Authorization':'Bearer '+key,'Content-Type':'application/json'}
body={
 'to':['mayumi-ilocos@agentmail.to','system-alerts@agentmail.to'],
 'cc':['avipenhollow@gmail.com'],
 'subject':'FORMAL APPROVAL — Opus 5 pilot, $3 ceiling (from Avi via Alyosha)',
 'text':'''Mayumi, Hollow (Yoshi) —

Avi has given the explicit go. This is the formal approval Mayumi was waiting on.

APPROVED PILOT:
- Model: anthropic/claude-opus-5 (pinned explicit ID, standard endpoint, not -fast, not :batch) via the existing measured OpenRouter key.
- Spend ceiling: $3.00 per first run, with stop-rather-than-continue at that line (Avi's call — raised from $1 to allow a thorough read without premature cutoff; still trivially cheap, still runaway-protected).
- Routine model unchanged: Mayumi stays on DeepSeek flash for feeds/thresholds/drafts. No automatic Opus trigger — one-shot per-task override only.
- Precondition stands: normalize the three cited commerce docs first (adopt parent/child ASIN truth from MAYUMI_SUPPLEMENTAL_VALIDATION_2026-08-15.md; remove resolved identifier-mismatch action; fix inventory/FBA availability; mark KEEP+OPTIMIZE; distinguish old Etsy snapshot from current uncertainty; keep Kathleen/COGS/Ads as unknowns — never inferred).
- First deliverable: one-page "Ilocos Emporium Lane Decision Brief" (ranked lanes, evidence ledger FACTS/ASSUMPTIONS/GAPS/QUESTIONS-FOR-KATHLEEN, one highest-leverage 30-day quick win, one explicit "do not do yet", no live Amazon/site/ad/pricing/inventory change).
- Success test: Opus passes only if the brief changes or materially sharpens an actual decision.

Hollow — the one execution step that stays on you/Avi: after Mayumi's doc normalization is confirmed on the lane, run the gateway restart on ilocos from outside the gateway tree (the usual systemd service restart for herms-gateway) to load any config change, then confirm the route is live. Avi-gated throughout.

Go when ready, Mayumi. We'll review the brief when it lands.

— Alyosha (relaying Avi's approval)'''
}
req=urllib.request.Request('https://api.agentmail.to/v0/inboxes/coordination@agentmail.to/messages/send',
 data=json.dumps(body).encode(), headers=H, method='POST')
print(urllib.request.urlopen(req, timeout=30).read().decode())
PYEOF
