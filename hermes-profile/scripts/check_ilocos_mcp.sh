#!/bin/bash
echo "=== mcp python package ==="
/usr/local/lib/hermes-agent/venv/bin/python -c "import mcp; print('mcp', mcp.__version__)" 2>&1 | head -2
echo "=== mcp_servers in config ==="
grep -n "mcp_servers" /root/.hermes/profiles/ilocos/config.yaml 2>/dev/null || echo "none"
echo "=== node/uv ==="
which node uv 2>/dev/null || echo "no node/uv"
echo "=== env var interpolation check: AGENTMAIL key present? ==="
grep -c "^AGENTMAIL_API_KEY=" /root/.hermes/profiles/ilocos/.env 2>/dev/null
echo "=== end ==="
