#!/bin/bash
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
python3 - << "PYEOF"
import json
d=json.load(open("/root/.hermes/profiles/ilocos/google_token.json"))
print("scopes:", d.get("scopes"))
print("account:", d.get("account"))
print("expiry:", d.get("expiry"))
print("has token:", bool(d.get("token")))
print("has refresh:", bool(d.get("refresh_token")))
print("client_id startswith 8 chars:", d.get("client_id","")[:8])
PYEOF
'
