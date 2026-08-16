#!/bin/bash
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
export HERMES_HOME=/root/.hermes/profiles/ilocos
/usr/local/lib/hermes-agent/venv/bin/python /root/.hermes/profiles/ilocos/skills/productivity/google-workspace/scripts/setup.py --check-live 2>&1 | grep -v "HERMES_HOME fallback" | head -8
'
