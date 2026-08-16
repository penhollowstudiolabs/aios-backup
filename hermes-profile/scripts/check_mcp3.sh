#!/bin/bash
echo "=== full traceback of streamable_http import ==="
/usr/local/lib/hermes-agent/venv/bin/python -c "from mcp.client.streamable_http import streamablehttp_client; print('streamable_http OK')" 2>&1 | tail -15
echo "=== check starlette/anyio present ==="
/usr/local/lib/hermes-agent/venv/bin/python -c "import anyio; print('anyio OK')" 2>&1 | tail -3
/usr/local/lib/hermes-agent/venv/bin/python -c "import starlette; print('starlette OK')" 2>&1 | tail -3
