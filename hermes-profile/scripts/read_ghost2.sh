#!/bin/bash
cd /root/.hermes
export $(grep AGENTMAIL_API_KEY .env | xargs)
python3 - << 'PYEOF'
import urllib.request, json, os, urllib.parse
key=os.environ.get('AGENTMAIL_API_KEY','')
mid='<010001a015092305-9badcd69-f698-4bdc-a6d7-dfd18f3b2dd0-000000@email.amazonses.com>'
u='https://api.agentmail.to/v0/inboxes/coordination@agentmail.to/messages/'+urllib.parse.quote(mid)
r=urllib.request.Request(u, headers={'Authorization':'Bearer '+key})
d=json.loads(urllib.request.urlopen(r, timeout=30).read())
print('SUBJECT:', d.get('subject'))
print('FROM:', d.get('from'))
print('keys:', list(d.keys()))
for k in ['text','body','content','html','text_body']:
    if d.get(k): print(f'=== {k} ===\n', (d[k] if isinstance(d[k],str) else str(d[k]))[:6500])
PYEOF