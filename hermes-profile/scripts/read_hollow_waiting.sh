#!/bin/bash
cd /root/.hermes
export $(grep AGENTMAIL_API_KEY .env | xargs)
python3 - << 'PYEOF'
import urllib.request, json, os, urllib.parse
key=os.environ.get('AGENTMAIL_API_KEY','')
mid='<010001a007a6fcf8-9c696f6a-d18a-48a4-82e0-1e0380adfabf-000000@email.amazonses.com>'
u='https://api.agentmail.to/v0/inboxes/coordination@agentmail.to/messages/'+urllib.parse.quote(mid)
r=urllib.request.Request(u, headers={'Authorization':'Bearer '+key})
d=json.loads(urllib.request.urlopen(r, timeout=30).read())
print('=== subject:', d.get('subject'))
print('=== timestamp:', d.get('timestamp'))
print('=== body ===')
print((d.get('text') or '')[:4000])
PYEOF
