#!/bin/bash
cd /root/.hermes
export $(grep AGENTMAIL_API_KEY .env | xargs)
python3 - << 'PYEOF'
import urllib.request, json, os, urllib.parse
key=os.environ.get('AGENTMAIL_API_KEY','')
mid='<010001a007a4230a-c0327364-d6d9-4377-947d-bce933b1e1c7-000000@email.amazonses.com>'
u='https://api.agentmail.to/v0/inboxes/coordination@agentmail.to/messages/'+urllib.parse.quote(mid)
r=urllib.request.Request(u, headers={'Authorization':'Bearer '+key})
d=json.loads(urllib.request.urlopen(r, timeout=30).read())
print('=== subject:', d.get('subject'))
print('=== timestamp:', d.get('timestamp'))
print('=== body ===')
print((d.get('text') or '')[:4000])
PYEOF
