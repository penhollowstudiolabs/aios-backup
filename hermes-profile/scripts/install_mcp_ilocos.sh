#!/bin/bash
echo "=== installing mcp package into ilocos Hermes venv ==="
/usr/local/lib/hermes-agent/venv/bin/pip install --upgrade mcp 2>&1 | tail -4
echo "=== verify import ==="
/usr/local/lib/hermes-agent/venv/bin/python -c "import mcp; print('mcp OK, version', getattr(mcp,'__version__','?'))" 2>&1 | head -2
echo "=== verify streamable_http client ==="
/usr/local/lib/hermes-agent/venv/bin/python -c "from mcp.client.streamable_http import streamablehttp_client; print('streamable_http OK')" 2>&1 | head -2
