#!/bin/bash
# Daily OpenRouter usage snapshot — writes one line, silent to Avi.
# Delivers only to local (no Telegram spam). Read when you want the trend.
cd /root/.hermes/profiles/alyosha
export $(grep OPENROUTER_API_KEY .env | xargs) 2>/dev/null
OUT=/root/vault/Efforts/Captain-Avi-System/openrouter_usage_log.csv
[ -f "$OUT" ] || echo "date_pt,usage_usd,remaining_est" > "$OUT"
# EST now via /etc/timezone
PT=$(TZ=America/Los_Angeles date +%Y-%m-%d\ %H:%M)
usage=$(curl -s "https://openrouter.ai/api/v1/credits" -H "Authorization: Bearer $OPENROUTER_API_KEY" 2>/dev/null | python3 -c "import sys,json;d=json.load(sys.stdin).get('data',{});print(round(d.get('total_usage',0),2))" 2>/dev/null)
[ -n "$usage" ] && echo "$PT,$usage" >> "$OUT"
exit 0