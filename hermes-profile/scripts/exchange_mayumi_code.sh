#!/bin/bash
ssh -o ConnectTimeout=8 -o BatchMode=yes ilocos '
export HERMES_HOME=/root/.hermes/profiles/ilocos
PY=/usr/local/lib/hermes-agent/venv/bin/python
GSETUP="$PY /root/.hermes/profiles/ilocos/skills/productivity/google-workspace/scripts/setup.py"
CODE="4/0ATsMZqBOTlgbxFvruOFYKnEaN8shi6DCqvwWuNdKpbDmou5KbyF8uh9Di8r-7RcwZJQ0_w"
$GSETUP --auth-code "http://localhost:1/?state=tBTSgaHjrLEKZ7nWOM20UEFNcf2YJ7&code=$CODE" 2>&1 | grep -v "HERMES_HOME fallback" | head -8
'
