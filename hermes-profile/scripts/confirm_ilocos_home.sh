#!/bin/bash
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
echo "--- HERMES_HOME resolution for ilocos profile ---"
echo "profile home candidates:"
ls -d /root/.hermes/profiles/ilocos 2>/dev/null
echo "--- where does the existing token live? ---"
ls -la /root/.hermes/profiles/ilocos/google_token.json /root/.hermes/google_token.json 2>/dev/null
echo "--- active profile from env ---"
echo "HERMES_HOME=$HERMES_HOME"
cat /root/.hermes/profiles/ilocos/.env 2>/dev/null | grep -c "^" >/dev/null
'
