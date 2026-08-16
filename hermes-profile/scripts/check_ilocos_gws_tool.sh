#!/bin/bash
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
echo "--- google-workspace toolset enabled in config? ---"
grep -niE "google|workspace|gws" /root/.hermes/profiles/ilocos/config.yaml 2>/dev/null | head
echo "--- google-workspace skill present ---"
ls /root/.hermes/profiles/ilocos/skills/productivity/google-workspace/ 2>/dev/null && echo "skill present"
echo "--- gateway running? (tools loaded at startup) ---"
ps -ef | grep "profile ilocos gateway run" | grep -v grep | awk "{print \"gateway pid:\", \$2}" | head -1
echo "--- gateway start time ---"
ps -o lstart= -p $(pgrep -f "profile ilocos gateway run" | head -1) 2>/dev/null
'
