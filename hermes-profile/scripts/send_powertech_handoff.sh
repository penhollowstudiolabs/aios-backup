#!/bin/bash
cd /root/.hermes
export $(grep AGENTMAIL_API_KEY .env | xargs)
python3 - << 'PYEOF'
import urllib.request, json, os
key=os.environ.get('AGENTMAIL_API_KEY','')
H={'Authorization':'Bearer '+key,'Content-Type':'application/json'}
body={
 'to':['system-alerts@agentmail.to'],
 'cc':['avipenhollow@gmail.com'],
 'subject':'OWNER HANDOFF — Power & Tech Watch scan moves to Hollow (per Avi)',
 'text':'''Hollow — Avi decided: the Power & Tech Watch web-scan is now YOURS. This hands you the producer role for the brief's web-sourced section.

WHY (Avi's correction of me, and he's right): you run from a residential IP and read the web freely; my aios can't reach the internet without a paid Firecrawl/Nous lane, which Avi rightly refuses to fund. The 8/10 ownership record already flagged this capability split ("Hollow = laptop-local live evidence. Browser-side = Hollow's lane"). Avi allocated the P&T scan to you. Frictionless = cost-free, uses each agent where they're strong, kills the Firecrawl need entirely.

THE MECHANIC (already wired, no config change needed)
The 5:30am brief reads the MOST RECENT file in the vault folder:
   /root/vault/Calendar/Power-Tech-Watch/
So: YOU produce a dated scan there (today UTC), and the brief folds it in automatically next morning. I paused my aios cron for this (power-tech-watch-scan, job e78cdf4f5981) — it was web-dead anyway. Deliverable = the vault file, not a Telegram message.

YOUR SCAN CONTRACT (Avi's spec — keep this exact voice)
Scope (cover ALL): (1) US admin: AI-chip export controls, AI policy/exec action, tariffs; (2) tech oligarchs: OpenAI/Anthropic/Google/Nvidia/Meta — products/pricing/policy/model/agent releases; (3) agent-economics: multi-agent adoption, skills-marketplace, AI-workforce/labor-arbitrage, deployment numbers; (4) regulatory/legal; (5) anything touching Avi's stack (SPED SaaS, Ilocos/Amazon, Adarna, AIOS product).
Voice: critical-but-objective — treat administration AND oligarch claims as self-interested until sourced; report the item + competing views + one sharp skeptical line; no manufactured urgency; no "why this matters" patronizing; Avi is knowledgeable.
File: dated markdown in Calendar/Power-Tech-Watch/, e.g. Power-Tech-Watch/2026-08-16 - Power Tech Watch.md (follow the existing naming from past scans — check an existing file for format). If genuinely nothing material: write "No material moves today." — do NOT invent items.
The brief (me) folds your file in. If a week passes with no new file from you, I'll flag Avi on the lane, not silently.

HOW YOU WRITE THE FILE
You have laptop-local write access to the mirrored vault (Obsidian) — write to the same path there; ob-sync propagates it to aios and it's what the brief reads. If your write-permission is an issue, send the scan content to me on this lane and I'll file it — but the direct-target is you writing the vault file.

THAT'S THE FIX — cost-free, no Firecrawl, brief keeps its P+T section. Avi's watching. Confirm by filing tonight's scan.

— Alyosha'''
}
req=urllib.request.Request('https://api.agentmail.to/v0/inboxes/coordination@agentmail.to/messages/send',
 data=json.dumps(body).encode(), headers=H, method='POST')
print(urllib.request.urlopen(req, timeout=30).read().decode())
PYEOF