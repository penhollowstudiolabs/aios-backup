#!/bin/bash
# Provider-health watchdog: alert Telegram ONCE per PRIMARY-DOWN state change,
# silent when healthy. No repeated nagging while still down.
# Log path / cron cadence are set for the aios (Alyosha) box — adjust per host.
LOG=/root/.hermes/profiles/alyosha/logs/errors.log
STATE=/tmp/provider_health_state
WINDOW=6h
NOW=$(date -u +%s)
THEN=$((NOW - 6*3600))

last_primary_fail=$(grep -h "requires available credits" "$LOG" 2>/dev/null \
  | grep -oE "^20[0-9-]+ [0-9:]+" | tail -1)
if [ -n "$last_primary_fail" ]; then
  fail_ts=$(date -d "$last_primary_fail" +%s 2>/dev/null)
else
  fail_ts=0
fi

DOWN=0
[ -n "$fail_ts" ] && [ "$fail_ts" -gt "$THEN" ] && DOWN=1

last_state=$(cat "$STATE" 2>/dev/null || echo "unknown")

if [ "$DOWN" = "1" ]; then
  if [ "$last_state" != "down" ]; then
    cnt=$(grep -hc "requires available credits" "$LOG" 2>/dev/null)
    echo "⚠️ Primary provider DOWN (last failure $last_primary_fail UTC) — running on fallback. $cnt failures. Top up or switch primary."
    echo "down" > "$STATE"
  fi
else
  if [ "$last_state" = "down" ]; then
    echo "✅ Primary provider back — currently serving normally."
    echo "up" > "$STATE"
  else
    echo "up" > "$STATE"
  fi
fi
exit 0