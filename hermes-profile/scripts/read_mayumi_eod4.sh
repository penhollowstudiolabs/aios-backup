#!/bin/bash
cd /root/.hermes
export $(grep AGENTMAIL_API_KEY .env | xargs)
python3 - << 'PYEOF'
import urllib.request, json, os, urllib.parse, re, html
key=os.environ.get('AGENTMAIL_API_KEY','')
# fetch single message; try html/text fields
mid='<010001a00dc8c749-ad0be2e3-5121-4f8a-9c7f-157eae78699c-000000@email.amazonses.com>'
for path in ['messages/'+urllib.parse.quote(mid), 'messages/'+urllib.parse.quote(mid)+'/raw',
             'messages/'+urllib.parse.quote(mid)+'?raw=true']:
    try:
        r=urllib.request.Request('https://api.agentmail.to/v0/inboxes/coordination@agentmail.to/'+path, headers={'Authorization':'Bearer '+key})
        raw=urllib.request.urlopen(r, timeout=30).read().decode('utf-8',errors='replace')
        print('=== path:', path, 'len', len(raw))
        # if html, strip tags
        if '<html' in raw.lower() or '<body' in raw.lower():
            # extract body-ish text
            body_m=re.search(r'<body[^>]*>(.*?)</body>', raw, re.S|re.I)
            txt = re.sub(r'<[^>]+>',' ', body_m.group(1) if body_m else raw)
            txt = html.unescape(re.sub(r'\s+',' ', txt))
            print(txt[:4000])
        else:
            print(raw[:4000])
        break
    except Exception as e:
        print('path',path,'err',str(e)[:100])
PYEOF