#!/bin/bash
cd /root/.hermes
export $(grep AGENTMAIL_API_KEY .env | xargs)
python3 - << 'PYEOF'
import urllib.request, json, os, urllib.parse
key=os.environ.get('AGENTMAIL_API_KEY','')
# list then find by id
r=urllib.request.Request('https://api.agentmail.to/v0/inboxes/coordination@agentmail.to/messages?limit=5', headers={'Authorization':'Bearer '+key})
d=json.loads(urllib.request.urlopen(r, timeout=30).read())
msgs=d.get('messages',d.get('data',[]))
for m in msgs:
    if 'Mayumi' in (m.get('subject') or '') or 'EOD' in (m.get('subject') or ''):
        print('SUBJECT:', m.get('subject'))
        print('FROM:', m.get('from'))
        print('=== BODY ===')
        print(m.get('text') or m.get('body') or m.get('content') or '')
        print('\n=== KEYS:', list(m.keys()))
PYEOF