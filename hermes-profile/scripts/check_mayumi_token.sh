#!/bin/bash
echo "=== Mayumi google_token.json (metadata only, NO secrets) ==="
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
python3 - << "PYEOF"
import json, time
try:
    d=json.load(open("/root/.hermes/profiles/ilocos/google_token.json"))
    print("keys:", list(d.keys()))
    print("expiry:", time.strftime("%Y-%m-%d %H:%M:%S %Z", time.localtime(d.get("expires_at",0))) if d.get("expires_at") else "n/a")
    print("token_type:", d.get("token_type"))
    print("scope:", d.get("scope"))
    print("refresh_token present:", bool(d.get("refresh_token")))
    print("client_id present:", bool(d.get("client_id")))
except Exception as e:
    print("ERR reading token:", e)
PYEOF
echo "--- google client secret scopes ---"
python3 -c "
import json
d=json.load(open('/root/.hermes/profiles/ilocos/google_client_secret.json'))
for k in d:
    if isinstance(d[k],dict) and 'client_id' in d[k]: print('client_id:', d[k]['client_id'][:20]+'...')
"
echo "--- google-workspace skill in profile? ---"
ls /root/.hermes/profiles/ilocos/skills/ 2>/dev/null | grep -iE "google|workspace|obsidian" | head
'
