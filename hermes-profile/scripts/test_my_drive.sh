#!/bin/bash
cd /root/.hermes/profiles/alyosha
python3 - << 'PYEOF'
import json, urllib.request, urllib.parse, time
# load token
tok=json.load(open("google_token.json"))
print("account field:", tok.get("account"))
print("scopes:", tok.get("scopes"))
print("expiry:", tok.get("expiry"))

def get_access(tok):
    # refresh
    data=urllib.parse.urlencode({
      "client_id": tok.get("client_id"),
      "client_secret": tok.get("client_secret"),
      "refresh_token": tok.get("refresh_token"),
      "grant_type":"refresh_token"}).encode()
    r=urllib.request.Request("https://oauth2.googleapis.com/token", data=data, method="POST")
    resp=json.loads(urllib.request.urlopen(r, timeout=30).read())
    return resp["access_token"], resp.get("scope")

try:
    access, scope = get_access(tok)
    print("REFRESH OK. scope:", scope)
    # about me
    req=urllib.request.Request("https://www.googleapis.com/drive/v3/about?fields=user,storageQuota", headers={"Authorization":"Bearer "+access})
    d=json.loads(urllib.request.urlopen(req, timeout=30).read())
    print("drive user:", d.get("user",{}).get("emailAddress"), "| display:", d.get("user",{}).get("displayName"))
    print("quota:", d.get("storageQuota",{}))
except urllib.error.HTTPError as e:
    print("HTTP", e.code, e.read().decode()[:300])
except Exception as e:
    print("ERR:", type(e).__name__, str(e)[:300])
PYEOF
