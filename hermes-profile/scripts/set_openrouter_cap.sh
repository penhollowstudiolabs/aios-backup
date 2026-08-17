#!/bin/bash
cd /root/.hermes/profiles/alyosha
export $(grep OPENROUTER_API_KEY .env | xargs) 2>/dev/null
echo "=== current key limits before ==="
curl -s "https://openrouter.ai/api/v1/auth/key" -H "Authorization: Bearer $OPENROUTER_API_KEY" | python3 -c "import sys,json;d=json.load(sys.stdin).get('data',{});print('usage:',round(d.get('usage',0),2),'limit:',d.get('limit'),'is_free_tier:',d.get('is_free_tier'))"
echo ""
echo "=== try setting a monthly credit limit (v1 patched). Attempt key-management endpoint ==="
# OpenRouter credit-limit endpoints
for ep in "https://openrouter.ai/api/v1/credits" "https://openrouter.ai/api/v1/auth/limit" "https://openrouter.ai/api/v1/key/limit"; do
  echo "-- $ep --"
  curl -s -X GET "$ep" -H "Authorization: Bearer $OPENROUTER_API_KEY" 2>/dev/null | head -c 200; echo
done