#!/bin/bash
echo "=== raw header line (should be full env ref) ==="
grep "Authorization" /root/.hermes/profiles/ilocos/config.yaml | sed 's/Bearer.*/Bearer <checking>/'
grep -n "Authorization" -A0 /root/.hermes/profiles/ilocos/config.yaml | head -3
echo "=== exact match check ==="
if grep -q 'Bearer ${env:AGENTMAIL_API_KEY}' /root/.hermes/profiles/ilocos/config.yaml; then
  echo "OK: full env ref present"
else
  echo "PROBLEM: env ref not exact"
  grep "Authorization" /root/.hermes/profiles/ilocos/config.yaml
fi
