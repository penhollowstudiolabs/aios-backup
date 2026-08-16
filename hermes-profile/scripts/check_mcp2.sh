#!/bin/bash
echo "=== mcp package structure ==="
/usr/local/lib/hermes-agent/venv/bin/python -c "
import mcp, os
print('version:', getattr(mcp,'__version__','?'))
print('file:', mcp.__file__)
import pkgutil
mods=[m.name for m in pkgutil.iter_modules(mcp.__path__)]
print('submodules:', mods)
# look for client
try:
    from mcp import client
    print('client submodules:', [m.name for m in pkgutil.iter_modules(client.__path__)])
except Exception as e:
    print('client err:', e)
" 2>&1 | head -20
echo "=== search for http client in site-packages ==="
/usr/local/lib/hermes-agent/venv/bin/python -c "
import os, glob
sp='/usr/local/lib/hermes-agent/venv/lib/python3.11/site-packages'
for p in glob.glob(sp+'/mcp*/**/*.py', recursive=True):
    if 'streamable' in p.lower() or 'http' in p.lower():
        print(p.replace(sp,''))
" 2>&1 | head -20
