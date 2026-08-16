#!/bin/bash
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
cd /root/.hermes/profiles/ilocos
python3 - << "PYEOF"
import json, os, urllib.request
tok=json.load(open("google_token.json"))
# refresh
import urllib.parse
data=urllib.parse.urlencode({
  "client_id": tok["client_id"],
  "client_secret": tok["client_secret"],
  "refresh_token": tok["refresh_token"],
  "grant_type": "refresh_token"
}).encode()
try:
    r=urllib.request.Request("https://oauth2.googleapis.com/token", data=data, method="POST")
    resp=json.loads(urllib.request.urlopen(r, timeout=30).read())
    access=resp["access_token"]
    print("REFRESH OK — new access token issued")
    print("scope:", resp.get("scope"))
    # live drive test: list first 5 files in "My Drive"
    req=urllib.request.Request("https://www.googleapis.com/drive/v3/files?pageSize=5&fields=files(id,name,mimeType)",
        headers={"Authorization":"Bearer "+access})
    d=json.loads(urllib.request.urlopen(req, timeout=30).read())
    files=d.get("files",[])
    print("LIVE DRIVE READ OK — files:", len(files))
    for f in files[:5]:
        print("  -", f.get("name"), "|", f.get("mimeType"))
except urllib.error.HTTPError as e:
    print("HTTP", e.code, e.read().decode()[:300])
except Exception as e:
    print("ERR:", type(e).__name__, str(e)[:300])
PYEOF
'
