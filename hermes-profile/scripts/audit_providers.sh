#!/bin/bash
cd /root/.hermes/profiles/alyosha
echo "=== 1. Current live model config ==="
grep -A2 "^model:" config.yaml 2>/dev/null | head -4
grep -A2 "^fallback_model:" config.yaml 2>/dev/null | head -3
grep -A3 "^auxiliary:" config.yaml 2>/dev/null | head -5
echo ""
echo "=== 2. Nous failure start + count ==="
grep -h "requires available credits" logs/errors.log 2>/dev/null | grep -oE "^20[0-9-]+ [0-9:]+" | head -1
echo "total failures: $(grep -hc 'requires available credits' logs/errors.log 2>/dev/null)"
echo ""
echo "=== 3. Fallback serving signals (recent provider mix) ==="
grep -h "OpenAI client created" logs/agent.log 2>/dev/null | grep -oE "provider=(nous|openrouter)" | sort | uniq -c
echo ""
echo "=== 4. Nous auth token present? ==="
python3 -c "
import json
d=json.load(open('auth.json'))
for k in d:
    kl=k.lower()
    if 'nous' in kl or 'portal' in kl:
        v=d[k]
        print(k, ':', 'token' if (isinstance(v,dict) and v.get('token')) else '(no token)')
" 2>&1 | head
echo ""
echo "=== 5. OpenRouter measured spend + cap ==="
grep -iE "OPENROUTER_API_KEY" .env 2>/dev/null | sed 's/=.*/=<set>/' | head -1
echo ""
echo "=== 6. Daily Brief / power-tech / Mayumi cron health (last status) ==="
echo "checking cron output dirs"
ls -1t /root/.hermes/profiles/alyosha/cron/output/a85b2d174ce5/ 2>/dev/null | head -3
ls -1t /root/.hermes/profiles/alyosha/cron/output/e78cdf4f5981/ 2>/dev/null | head -3