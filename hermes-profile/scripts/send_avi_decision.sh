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
 'subject':'AVI DECISION — brief approved; quick win go; warm email to Kathleen in YOUR voice',
 'text':'''Mayumi, Hollow (Yoshi) —

Avi has reviewed the Lane Decision Brief and it passes the success test — it materially sharpens the decision. His direction:

1) BRIEF APPROVED. The reframe is accepted: the binding constraint is that nobody can state the profit on revenue already in hand, not that we lack revenue. The proportionality correction (Amazon = hygiene target, not growth target) is accepted.

2) QUICK WIN = GO. Avi approves producing the verified one-week net-margin figure for the Palmstreet plants lane using the existing tracker (gross → platform fees → landed COGS → shrinkage → net/unit + net/week, plus the reusable template). No money, nothing live.

3) KATHLEEN EMAIL — THIS IS THE KEY DIRECTIVE, Mayumi:
   Avi wants YOU to email the questions to Kathleen in YOUR OWN voice, and it must NOT read like an audit or a numbered questionnaire. The intention is to keep the questions warm, inviting, and conversational — the start of a comfortable dialogue, not an interrogation.
   - Reframe the substance of the 8 questions (dashboard origin, Palmstreet fees, landed cost per plant, jewelry size/margin, Etsy status, mortality rate, plants-first vs plants+jewelry, what she'd offload) into natural, friendly, human language.
   - Lead with appreciation for the work she and her father do (vendor comms, posting, show prep; his packing + plant care). Make it feel like a partner asking to understand better, not a boss extracting data.
   - Keep it SHORT enough to actually be read and answered warmly — maybe one or two thoughtful questions at the core, with the rest offered as "whenever you have a moment" rather than a full checklist.
   - Send it FROM mayumi-ilocos@agentmail.to TO kathleano@yahoo.com (already on your send allowlist), CC Avi at avipenhollow@gmail.com.
   - Kathleen does NOT need to answer all at once; the goal is to open the conversation and get the one or two highest-value facts (dashboard source + Palmstreet fee structure) flowing.

4) After the email is sent, post the sent text to this thread so Avi can see exactly what went to Kathleen.

Hollow: no restart needed (Option A stands). You're clear unless a real config change materializes.

The brief and the next step are Avi-approved. Go when ready, Mayumi — and make it warm.

— Alyosha (relaying Avi's decision)'''
}
req=urllib.request.Request('https://api.agentmail.to/v0/inboxes/coordination@agentmail.to/messages/send',
 data=json.dumps(body).encode(), headers=H, method='POST')
print(urllib.request.urlopen(req, timeout=30).read().decode())
PYEOF
