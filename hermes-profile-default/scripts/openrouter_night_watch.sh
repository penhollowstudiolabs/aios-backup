#!/bin/bash
# OpenRouter night watch — silent unless something's off.
# Runs once nightly (off-peak ~3:30am PT). Pings Avi ONLY on:
#   A) remaining credits fell below the LOW floor (alerts once per crossing)
#   B) abnormal burn vs last check (usage jumped a lot since prior snapshot)
# Quiet when healthy. Zero tokens (script-only).
cd /root/.hermes/profiles/alyosha
export $(grep OPENROUTER_API_KEY .env | xargs) 2>/dev/null
STATE=/tmp/openrouter_watch_state
LOW_FLOOR=5.00        # alert if remaining < $5
BURN_TOLERANCE=8.00   # alert if usage climbed > $8 since last check

cred=$(curl -s "https://openrouter.ai/api/v1/credits" -H "Authorization: Bearer $OPENROUTER_API_KEY" 2>/dev/null \
  | python3 -c "import sys,json;d=json.load(sys.stdin).get('data',{});print(d.get('total_credits',0),d.get('total_usage',0))" 2>/dev/null)
[ -z "$cred" ] && exit 0   # endpoint unreachable tonight — stay quiet, retry tomorrow
total=$(echo "$cred" | cut -d' ' -f1); usage=$(echo "$cred" | cut -d' ' -f2)
remaining=$(python3 -c "print(round($total-$usage,2))")

# state: prev_usage prev_remaining
prev_usage=$(cat "$STATE" 2>/dev/null | cut -d' ' -f1)
prev_remaining=$(cat "$STATE" 2>/dev/null | cut -d' ' -f2)

msg=""
if python3 -c "exit(0 if $remaining < $LOW_FLOOR else 1)" 2>/dev/null; then
  # low balance — only alert on the crossing (going from above-floor to below), not every night
  [ -n "$prev_remaining" ] && \
    python3 -c "exit(0 if $prev_remaining >= $LOW_FLOOR and $remaining < $LOW_FLOOR else 1)" 2>/dev/null && \
    msg="⚠️ OpenRouter low: **\$$remaining** left (was \$$prev_remaining). Top-up may be due. "
fi
if [ -z "$msg" ] && [ -n "$prev_usage" ]; then
  # abnormal burn check
  python3 -c "exit(0 if ($usage - $prev_usage) > $BURN_TOLERANCE else 1)" 2>/dev/null && \
    msg="⚠️ OpenRouter burn spike: usage +\$$(python3 -c "print(round($usage-$prev_usage,2))") since last check (now \$$usage total). Investigate. "
fi

# persist state regardless
echo "$usage $remaining" > "$STATE"
[ -n "$msg" ] && echo "$msg"
exit 0