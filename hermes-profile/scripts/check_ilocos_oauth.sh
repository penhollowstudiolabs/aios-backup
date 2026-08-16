#!/bin/bash
echo "=== VPS1 ilocos google setup ==="
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
echo "--- client secret app name (id first 12) ---"
python3 -c "
import json
d=json.load(open(\"/root/.hermes/profiles/ilocos/google_client_secret.json\"))
for k in d:
    if isinstance(d[k], dict) and \"client_id\" in d[k]:
        c=d[k]; print(\"installed app client_id:\", c[\"client_id\"][:12]+\"...\"); print(\"auth_uri:\", c.get(\"auth_uri\"))
"
echo "--- does the gws/google-workspace tool exist in hermes? ---"
ls /usr/local/lib/hermes-agent/tools/ 2>/dev/null | grep -iE "gws|google|workspace|gdrive"
echo "--- gws CLI on path? ---"
which gws 2>/dev/null || echo "no gws cli"
echo "--- existing google integration mount ---"
grep -iE "google|integrations" /root/.hermes/profiles/ilocos/config.yaml 2>/dev/null | head
'
