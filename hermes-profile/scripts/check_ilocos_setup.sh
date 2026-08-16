#!/bin/bash
echo "=== does ilocos profile have google-workspace skill/setup.py? ==="
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
ls /root/.hermes/profiles/ilocos/skills/ 2>/dev/null | grep -iE "google|workspace" | head
find /root/.hermes/profiles/ilocos/skills -name "setup.py" -path "*google*" 2>/dev/null | head
echo "--- check HERMES_HOME shared skills ---"
ls /root/.hermes/skills/productivity/google-workspace/scripts/setup.py 2>/dev/null && echo "setup.py present in shared skills"
'
