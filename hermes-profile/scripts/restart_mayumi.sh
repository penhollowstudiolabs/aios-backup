#!/bin/bash
# Detached one-shot: restart Mayumi's Hermes gateway on VPS1 (ilocos)
# to load the new auxiliary.vision block, then verify.
set -u
LOG="/tmp/restart_mayumi_gateway.log"
{
  echo "=== $(date -Is) restarting hermes-gateway-ilocos ==="
  ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos 'systemctl restart hermes-gateway-ilocos.service' 2>&1
  sleep 4
  ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos 'echo "active: $(systemctl is-active hermes-gateway-ilocos.service)"; echo "pid: $(ps -ef | grep \"profile ilocos gateway run\" | grep -v grep | awk "{print \$2}")"'
} >> "$LOG" 2>&1
exit 0
