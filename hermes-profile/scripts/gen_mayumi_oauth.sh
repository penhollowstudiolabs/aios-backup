#!/bin/bash
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
PY=/usr/local/lib/hermes-agent/venv/bin/python
GSETUP="$PY /root/.hermes/profiles/ilocos/skills/productivity/google-workspace/scripts/setup.py"
echo "=== help ==="
$GSETUP --help 2>&1 | head -25
echo ""
echo "=== consent URL ==="
$GSETUP --auth-url 2>&1 | head -8
'
