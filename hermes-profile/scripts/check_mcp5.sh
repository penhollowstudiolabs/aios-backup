#!/bin/bash
echo "=== Hermes MCP discovery source ==="
grep -rn "streamablehttp_client\|streamable_http\|from mcp" /usr/local/lib/hermes-agent/hermes_cli/ /usr/local/lib/hermes-agent/tools/ 2>/dev/null | grep -iE "import|streamable" | head -20
echo "=== discover_mcp_tools location ==="
grep -rln "discover_mcp_tools\|streamablehttp\|streamable_http" /usr/local/lib/hermes-agent/ 2>/dev/null | grep -v site-packages | head -10
