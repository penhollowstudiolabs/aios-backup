#!/bin/bash
# Provider-health watchdog: alert Telegram ONCE per PRIMARY-DOWN state change,
# silent when healthy. Prevents a dead primary from coasting silently on the
# fallback for a day (the 8/16 Nous-outage failure mode).
#
# Drop-in for a no_agent cron: schedule */15, deliver=origin, script=this path.
# Detects: Nous payment-blank 404s ("requires available credits"). Extend the
# grep pattern if another provider becomes primary.
LOG=${1:-/root/.hermes/profiles/alyosha/logs/errors.log}
STATE=/tmp/provider_health_state
WINDOW_H=${WINDOW_H:-6}
NOW=$(date -u +%s)
THEN=$((NOW - WINDOW_H*3600))

last_fail=$(grep -h "requires available credits" "$LOG" 2>/dev/null \
  | grep -oE "^20[0-9-]+ [0-9:]+" | tail -1)
if [ -n "$last_fail" ]; then
  fail_ts=$(date -d "$last_fail" +%s 2>/dev/null); else fail_ts=0
fi

DOWN=0
[ -n "$fail_ts" ] && [ "$fail_ts" -gt "$THEN" ] && DOWN=1
last_state=$(cat "$STATE" 2>/dev/null || echo "unknown")

if [ "$DOWN" = "1" ]; then
  if [ "$last_state" != "down" ]; then
    cnt=$(grep -hc "requires available credits" "$LOG" 2>/dev/null)
    echo "⚠️ Nous primary DOWN (last failure $last_fail UTC) — running on OpenRouter fallback. $cnt failures. Top up Nous or switch primary."
    echo "down" > "$STATE"
  fi
else
  if [ "$last_state" = "down" ]; then
    echo "✅ Nous primary back — currently serving normally."
  fi
  echo "up" > "$STATE"
fi
exit 0