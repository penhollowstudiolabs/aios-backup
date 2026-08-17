#!/bin/bash
cd /root/.hermes
export $(grep OPENROUTER_API_KEY .env | xargs) 2>/dev/null
echo "=== 1. OpenRouter key balance + cap (from the source) ==="
for i in 1 2 3; do
  out=$(curl -s "https://openrouter.ai/api/v1/auth/key" -H "Authorization: Bearer $OPENROUTER_API_KEY")
  echo "$out" | python3 -c "import sys,json;d=json.load(sys.stdin);u=d.get('data',{});print('usage USD:',round(u.get('usage',0),2),'| limit:',u.get('limit'),'| is_free_tier:',u.get('is_free_tier'),'| limit_remaining:',u.get('limit_remaining'))" 2>/dev/null && break
  echo "retry $i (got: ${out:0:80})"; sleep 2
done
echo ""
echo "=== 2. Is the 25/mo a hard limit or a note? read config ==="
grep -riE "limit|25|cap" /root/.hermes/profiles/alyosha/config.yaml 2>/dev/null | grep -iE "openrouter|limit" | head -5
echo "config has no openrouter limit key explicitly -> checking env/keys"; grep -iE "OPENROUTER.*(LIMIT|CAP)" /root/.hermes/.env /root/.hermes/profiles/alyosha/.env 2>/dev/null | sed 's/=.*/=<set>/'
echo ""
echo "=== 3. Active production crons + their runtime ==="
python3 -c "
import json
d=json.load(open('/root/.hermes/profiles/alyosha/cron/jobs.json'))
jobs=d.get('jobs',d if isinstance(d,list) else d.get('data',[]))
for j in jobs:
    print('-', j.get('name'), '| enabled:', j.get('enabled'), '| no_agent:', bool(j.get('no_agent')), '| model:', j.get('model') or '(n/a)')
" 2>/dev/null | head -20