#!/bin/bash
cd /root/.hermes/profiles/alyosha
python3 - << 'PYEOF'
import json, urllib.request, urllib.parse
tok=json.load(open("google_token.json"))
data=urllib.parse.urlencode({
  "client_id": tok.get("client_id"), "client_secret": tok.get("client_secret"),
  "refresh_token": tok.get("refresh_token"), "grant_type":"refresh_token"}).encode()
r=urllib.request.Request("https://oauth2.googleapis.com/token", data=data, method="POST")
access=json.loads(urllib.request.urlopen(r, timeout=30).read())["access_token"]

FID="18fhEXWfewM8IBZYZBDeNq3LHod_3v5lU"
def drive(url):
    req=urllib.request.Request(url, headers={"Authorization":"Bearer "+access})
    return json.loads(urllib.request.urlopen(req, timeout=30).read())

# folder metadata
try:
    f=drive(f"https://www.googleapis.com/drive/v3/files/{FID}?fields=id,name,mimeType,owners,shared")
    print("FOLDER:", f.get("name"), "|", f.get("mimeType"))
    print("owners:", [o.get("emailAddress") for o in f.get("owners",[])])
    print("shared:", f.get("shared"))
except Exception as e:
    print("folder meta ERR:", type(e).__name__, str(e)[:200])

# list contents
try:
    d=drive(f"https://www.googleapis.com/drive/v3/files?q='{FID}'+in+parents&pageSize=50&fields=files(id,name,mimeType)&supportsAllDrives=true&includeItemsFromAllDrives=true")
    print("=== contents:", len(d.get("files",[])))
    for x in d.get("files",[]):
        print("  -", x.get("name"), "|", x.get("mimeType"))
except Exception as e:
    print("list ERR:", type(e).__name__, str(e)[:200])
PYEOF
