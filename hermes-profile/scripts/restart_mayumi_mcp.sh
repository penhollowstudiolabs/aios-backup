#!/bin/bash
# Detached: restart Mayumi's gateway on ilocos to load AgentMail MCP, then verify.
set -u
LOG="/tmp/restart_mayumi_mcp.log"
{
  echo "=== $(date -Is) restarting hermes-gateway-ilocos for MCP ==="
  ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos 'systemctl restart hermes-gateway-ilocos.service' 2>&1
  sleep 8
  ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
    echo "active: $(systemctl is-active hermes-gateway-ilocos.service)"
    echo "pid: $(ps -ef | grep "profile ilocos gateway run" | grep -v grep | awk "{print \$2}")"
    echo "--- MCP/agentmail lines in gateway log ---"
    grep -iE "mcp|agentmail|streamable|discover" /root/.hermes/profiles/ilocos/logs/gateway.log 2>/dev/null | tail -40
    echo "--- gateway log tail ---"
    tail -15 /root/.hermes/profiles/ilocos/logs/gateway.log 2>/dev/null
  '
} >> "$LOG" 2>&1
exit 0
