#!/bin/bash
cd /root/.hermes
export $(grep AGENTMAIL_API_KEY .env | xargs)
python3 << 'PYEOF'
import urllib.request, json, os
key=os.environ.get('AGENTMAIL_API_KEY','')
def get(inbox):
    r=urllib.request.Request('https://api.agentmail.to/v0/inboxes/'+inbox+'/messages?limit=6', headers={'Authorization':'Bearer '+key})
    d=json.loads(urllib.request.urlopen(r, timeout=30).read())
    return d.get('messages',d.get('data',[]))
print('=== coordination lane (last 6) ===')
for m in get('coordination@agentmail.to'):
    f=m.get('from'); f=f.get('email') if isinstance(f,dict) else f
    print(' -', m.get('timestamp'), '|', m.get('subject'), '| from:', f, '| id:', m.get('message_id'))
PYEOF
