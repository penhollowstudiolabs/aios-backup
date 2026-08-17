#!/bin/bash
cd /root/.hermes
export $(grep AGENTMAIL_API_KEY .env | xargs)
python3 - << 'PYEOF'
import urllib.request, json, os, urllib.parse
key=os.environ.get('AGENTMAIL_API_KEY','')
def get(inbox):
    r=urllib.request.Request('https://api.agentmail.to/v0/inboxes/'+inbox+'/messages?limit=8', headers={'Authorization':'Bearer '+key})
    d=json.loads(urllib.request.urlopen(r, timeout=30).read())
    return d.get('messages',d.get('data',[]))
# reveal actual from/to incl the 16:09/16:19 ones
for ib in ['coordination@agentmail.to','system-alerts@agentmail.to']:
    print('===', ib)
    for m in get(ib):
        f=m.get('from'); f=f.get('email') if isinstance(f,dict) else f
        to=m.get('to')
        print(' ', m.get('timestamp'), '|', m.get('subject')[:60], '| FROM:', f, '| TO:', to)
PYEOF