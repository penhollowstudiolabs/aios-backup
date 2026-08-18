#!/bin/bash
cd /root/.hermes
export $(grep AGENTMAIL_API_KEY .env | xargs)
python3 - << 'PYEOF'
import urllib.request, json, os
key=os.environ.get('AGENTMAIL_API_KEY','')
for ib in ['coordination@agentmail.to','system-alerts@agentmail.to']:
    r=urllib.request.Request('https://api.agentmail.to/v0/inboxes/'+ib+'/messages?limit=10', headers={'Authorization':'Bearer '+key})
    d=json.loads(urllib.request.urlopen(r, timeout=30).read())
    msgs=d.get('messages',d.get('data',[]))
    print('===',ib)
    for m in msgs:
        f=m.get('from'); f=f.get('email') if isinstance(f,dict) else f
        print(' ', m.get('timestamp'),'| FROM:',f,'|', (m.get('subject') or '')[:70])
PYEOF