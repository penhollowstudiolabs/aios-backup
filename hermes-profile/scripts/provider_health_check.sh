#!/bin/bash
# Provider-health watchdog: alert Telegram ONCE per PRIMARY-DOWN state change,
# silent when healthy. No repeated nagging while still down.
LOG=/root/.hermes/profiles/alyosha/logs/errors.log
STATE=/tmp/provider_health_state
WINDOW=6h
NOW=$(date -u +%s)
THEN=$((NOW - 6*3600))

last_nous_fail=$(grep -h "requires available credits" "$LOG" 2>/dev/null \
  | grep -oE "^20[0-9-]+ [0-9:]+" | tail -1)
if [ -n "$last_nous_fail" ]; then
  nous_ts=$(date -d "$last_nous_fail" +%s 2>/dev/null)
else
  nous_ts=0
fi

DOWN=0
[ -n "$nous_ts" ] && [ "$nous_ts" -gt "$THEN" ] && DOWN=1

last_state=$(cat "$STATE" 2>/dev/null || echo "unknown")

if [ "$DOWN" = "1" ]; then
  if [ "$last_state" != "down" ]; then
    cnt=$(grep -hc "requires available credits" "$LOG" 2>/dev/null)
    echo "⚠️ Nous primary DOWN (last failure $last_nous_fail UTC) — running on OpenRouter fallback. $cnt failures. Top up Nous or switch primary."
    echo "down" > "$STATE"
  fi
  # else: already alerted while down — stay silent
else
  if [ "$last_state" = "down" ]; then
    echo "✅ Nous primary back — currently serving normally."
    echo "up" > "$STATE"
  else
    echo -n > "$STATE" 2>/dev/null || true
    echo "up" > "$STATE"
  fi
fi
exit 0