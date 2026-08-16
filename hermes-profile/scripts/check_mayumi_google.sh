#!/bin/bash
echo "=== Mayumi (ilocos) Google Workspace access ==="
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
echo "--- google token/creds in profile ---"
ls -la /root/.hermes/profiles/ilocos/google_token.json /root/.hermes/profiles/ilocos/*.json 2>/dev/null | head
echo "--- .env google keys (names only) ---"
grep -oE "^(GOOGLE|GMAIL|GWS|CLIENT_ID|CLIENT_SECRET|REFRESH)[A-Z_]*=" /root/.hermes/profiles/ilocos/.env 2>/dev/null | head
echo "--- hermes auth list (masked) ---"
/usr/local/lib/hermes-agent/venv/bin/hermes --profile ilocos auth list 2>&1 | head -20
echo "--- google-workspace tool/scripts present? ---"
ls /root/.hermes/profiles/ilocos/scripts/ 2>/dev/null | grep -iE "google|gws|gdrive|drive" | head
ls /usr/local/lib/hermes-agent/tools/ 2>/dev/null | grep -iE "google|gws|drive" | head
echo "--- config google/workspace section ---"
grep -niE "google|workspace|gws|drive" /root/.hermes/profiles/ilocos/config.yaml 2>/dev/null | head
'
