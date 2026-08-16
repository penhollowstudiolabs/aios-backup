#!/bin/bash
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
export HERMES_HOME=/root/.hermes/profiles/ilocos
PY=/usr/local/lib/hermes-agent/venv/bin/python
GSETUP="$PY /root/.hermes/profiles/ilocos/skills/productivity/google-workspace/scripts/setup.py"
echo "=== generating consent URL with HERMES_HOME set to ilocos profile ==="
$GSETUP --auth-url 2>&1 | grep -v "HERMES_HOME fallback" | head -5
'
