#!/bin/bash
cd /root/.hermes/profiles/alyosha
echo "=== 1. My Telegram outbound near the ghost times (23:31 & 06:06 PT) ==="
# ghost times: ~23:31 (8/17 night) and ~06:06 (8/18 morning) PT = 06:31 and 13:06 UTC
echo "--- gateway/agent logs, telegram outbound 2026-08-17 06:2x-06:3x UTC & 08-18 13:0x UTC ---"
grep -iE "telegram.*(send|outbound|deliver)|send_message" logs/agent.log logs/gateway.log 2>/dev/null | grep -E "2026-08-17 06:3[01]|2026-08-18 13:0[0-8]" | head -15
echo ""
echo "=== 2. Whose telegram bot is on MY side? (could I send stray greets?) ==="
grep -iE "telegram|bot_token|bot_token|TELEGRAM" config.yaml .env 2>/dev/null | sed 's/=.*/=<set>/' | head
echo ""
echo "=== 3. Do any of MY crons deliver to Telegram/telegram? ==="
python3 -c "
import json
d=json.load(open('cron/jobs.json'))
jobs=d.get('jobs',d if isinstance(d,list) else d.get('data',[]))
for j in jobs:
    deliv=j.get('deliver')
    if deliv and 'telegram' in str(deliv):
        print(' ', j.get('name'), '| enabled:', j.get('enabled'), '| deliver:', deliv)
"