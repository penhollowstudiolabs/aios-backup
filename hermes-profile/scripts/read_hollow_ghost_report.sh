#!/bin/bash
cd /root/.hermes
export $(grep AGENTMAIL_API_KEY .env | xargs)
python3 - << 'PYEOF'
import urllib.request, json, os, urllib.parse
key=os.environ.get('AGENTMAIL_API_KEY','')
mid='<010001a014a95b2e-b5a81fec-4b40-4ec8-8799-0d38ffa2f923-000000@email.amazonses.com>' if False else 'PLACEHOLDER'
# list to find the actual id
r=urllib.request.Request('https://api.agentmail.to/v0/inboxes/coordination@agentmail.to/messages?limit=3', headers={'Authorization':'Bearer '+key})
d=json.loads(urllib.request.urlopen(r, timeout=30).read())
for m in d.get('messages',d.get('data',[])):
    if 'Ghost messages' in (m.get('subject') or ''):
        print('FOUND id:', m['message_id'])
        print('SUBJECT:', m.get('subject'))
        print('timestamp:', m.get('timestamp'))
        txt=m.get('text') or m.get('body') or m.get('content')
        print('=== BODY ===')
        print((txt or '')[:6500])
PYEOF