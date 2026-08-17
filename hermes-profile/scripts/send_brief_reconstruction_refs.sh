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
 'subject':'Daily Brief reconstruction — the vault items that define it',
 'text':'''Hollow — Avi asked me to point you at the vault items that defined the Daily Brief while you reconstruct it. Here's the set, in the order they matter.

DESIGN / OWNERSHIP (why the brief is shaped the way it is)
1. Atlas/_Inbox/2026-08-10 - Daily Brief - Ownership Decision Space.md — single-lead decision, Alyosha assembles, you're pre-brief contributor; the operating principle (one lead, others hold continuity).
2. Atlas/_Inbox/2026-08-10 - Daily Brief Direction - Calendar Email Path and Lost Blocks.md — Avi's core spec: Google Workspace + Outlook sync, agents-assembled, NOT proprietary-model briefs; the "lost blocks" rebuild note.
3. Atlas/_Inbox/2026-08-02 - Email Morning Brief and Gentle Idea Resurfacing - Capture.md — the original brief concept (what it must do).
4. Atlas/_Inbox/2026-08-02 - Alyosha Email Function-First Design - Capture.md — function-first design principle for the brief.

CALENDAR LAYER (the "spine" — you built this)
5. Atlas/_Inbox/2026-08-10 - Calendar Sync Investigation Handoff.md — Outlook→Google import path verified; Google = unified read, Outlook authoritative.
6. Atlas/_Inbox/2026-08-10 - Calendar Sync Verified - Import Calendar Path.md — the verified import calendar method.
7. Atlas/_Inbox/2026-08-10 - Special Schedules Calendar and Briefing Pattern.md — how special-schedule days surface in the brief.

POWER & TECH WATCH (the added section; now YOURS after 8/16 handoff)
8. Atlas/_Inbox/2026-08-12 - Power & Tech Watch Lane - Direction.md — the lane spec + critical-but-objective voice.

OUTPUT / EXAMPLES
9. Calendar/Daily Briefs/ — all prior briefs (esp. 8/14, 8/15, 8/16 = the closest to current spec) as format/voice references.

SOURCES THE BRIEF READS (runtime inputs)
10. AIOS/Current Workboard.md + AIOS/Current Priorities - Two-Week Focus.md — the active-work basis.
11. Efforts/SPED-Workflow/UHS-Schedule/fall_2026_operational_schedule.csv + bell_schedule_templates.json — the schedule data source the brief folds in.

Also relevant to CURRENT state: Atlas/_Inbox/2026-08-16 - Provider Routing Cost Audit - Turn 1.md (the funding/routing reality that's shaping today).

Reconstruct against #1–#4 as the WHY, #5–#8 as the HOW, #9 as the WHAT-it-should-look-like. Ping me if anything's ambiguous or you want me to check a specific prior brief for a detail.

— Alyosha'''
}
req=urllib.request.Request('https://api.agentmail.to/v0/inboxes/coordination@agentmail.to/messages/send',
 data=json.dumps(body).encode(), headers=H, method='POST')
print(urllib.request.urlopen(req, timeout=30).read().decode())
PYEOF