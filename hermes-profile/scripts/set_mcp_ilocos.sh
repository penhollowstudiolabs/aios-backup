#!/bin/bash
H=/usr/local/lib/hermes-agent/venv/bin/hermes
echo "=== current mcp_servers ==="
$H --profile ilocos config get mcp_servers 2>&1 | head -5
echo "=== set agentmail MCP server (HTTP transport) ==="
$H --profile ilocos config set mcp_servers.agentmail.url "https://mcp.agentmail.to/mcp" 2>&1 | tail -3
$H --profile ilocos config set mcp_servers.agentmail.headers.Authorization "Bearer \${env:AGENTMAIL_API_KEY}" 2>&1 | tail -3
echo "=== verify config block ==="
grep -n "mcp_servers" -A6 /root/.hermes/profiles/ilocos/config.yaml 2>/dev/null | head -20
echo "=== yaml validate ==="
/usr/local/lib/hermes-agent/venv/bin/python -c "import yaml; yaml.safe_load(open('/root/.hermes/profiles/ilocos/config.yaml')); print('YAML OK')" 2>&1 | head -3
