#!/bin/bash
echo "=== Mayumi current model config ==="
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
grep -A2 "^model:" /root/.hermes/profiles/ilocos/config.yaml 2>/dev/null | head -4
echo "--- mcp_servers block ---"
grep -A4 "mcp_servers" /root/.hermes/profiles/ilocos/config.yaml 2>/dev/null | head -6
'
echo "=== can she reach OpenRouter opus-5 route? (read-only check) ==="
curl -s "https://openrouter.ai/api/v1/models/anthropic/claude-opus-5" 2>/dev/null | head -c 200
echo ""
