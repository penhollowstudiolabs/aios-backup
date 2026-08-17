#!/bin/bash
cd /root/.hermes
export $(grep AGENTMAIL_API_KEY .env | xargs)
python3 - << 'PYEOF'
import urllib.request, json, os, urllib.parse
key=os.environ.get('AGENTMAIL_API_KEY','')
mid='<010001a00b411d6a-42457999-c17a-4b24-a155-cfd16e1f1db4-000000@email.amazonses.com>'
u='https://api.agentmail.to/v0/inboxes/coordination@agentmail.to/messages/'+urllib.parse.quote(mid)
r=urllib.request.Request(u, headers={'Authorization':'Bearer '+key})
d=json.loads(urllib.request.urlopen(r, timeout=30).read())
t=d.get('text') or ''
# find where the quoted section begins (the "> 1. Nous Portal paid tiers")
idx=t.find('> 1. Nous Portal paid tiers')
if idx<0:
    idx=t.find('> Nous Portal paid')
print("=== chars 4500 to %d ===" % (idx if idx>0 else len(t)))
print(t[4500:idx if idx>0 else len(t)])
PYEOF