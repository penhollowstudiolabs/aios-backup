#!/bin/bash
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
cd /root/.hermes/profiles/ilocos
/usr/local/lib/hermes-agent/venv/bin/python - << "PYEOF"
import json, urllib.request, urllib.parse
tok=json.load(open("google_token.json"))
data=urllib.parse.urlencode({
  "client_id": tok.get("client_id"), "client_secret": tok.get("client_secret"),
  "refresh_token": tok.get("refresh_token"), "grant_type":"refresh_token"}).encode()
r=urllib.request.Request("https://oauth2.googleapis.com/token", data=data, method="POST")
resp=json.loads(urllib.request.urlopen(r, timeout=30).read())
access=resp["access_token"]
print("REFRESH OK. scope:", resp.get("scope"))
# drive about
req=urllib.request.Request("https://www.googleapis.com/drive/v3/about?fields=user,storageQuota", headers={"Authorization":"Bearer "+access})
d=json.loads(urllib.request.urlopen(req, timeout=30).read())
print("drive user:", d.get("user",{}).get("emailAddress"))
print("quota limit (GB): %.0f" % (int(d.get("storageQuota",{}).get("limit",0))/1e9))
# write test: create a file in the Mayumi folder
FID="18fhEXWfewM8IBZYZBDeNq3LHod_3v5lU"
meta=json.dumps({"name":"__drive_write_test__.txt","mimeType":"text/plain","parents":[FID]}).encode()
req=urllib.request.Request("https://www.googleapis.com/drive/v3/files?fields=id,name", data=meta,
    headers={"Authorization":"Bearer "+access,"Content-Type":"application/json"}, method="POST")
try:
    f=json.loads(urllib.request.urlopen(req, timeout=30).read())
    print("WRITE TEST OK — created:", f.get("name"), "| id:", f.get("id"))
except urllib.error.HTTPError as e:
    print("WRITE TEST FAIL:", e.code, e.read().decode()[:200])
PYEOF
'
