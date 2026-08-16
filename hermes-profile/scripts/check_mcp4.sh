#!/bin/bash
echo "=== exports in mcp.client.streamable_http ==="
/usr/local/lib/hermes-agent/venv/bin/python -c "
import mcp.client.streamable_http as m
print([x for x in dir(m) if not x.startswith('_')])
" 2>&1 | head
echo "=== what Hermes expects: grep hermes source for streamable http import ==="
grep -rn "streamablehttp_client\|streamable_http\|mcp.client" /usr/local/lib/hermes-agent/ 2>/dev/null | grep -iE "import|streamablehttp_client" | head -10
