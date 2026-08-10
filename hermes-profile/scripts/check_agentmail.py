#!/usr/bin/env python3
"""Watchdog: alert on new mail in coordination@agentmail.to (Hollow->Alyosha lane).

Watchdog pattern: non-empty stdout is delivered to Telegram; empty stdout = silent.
Tracks last-seen newest message timestamp in a state file so already-seen mail
never re-alerts. Uses the AGENTMAIL_API_KEY from ~/.hermes/.env.
"""
import json
import os
import sys
import urllib.request
from datetime import datetime

STATE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".agentmail_last_seen")
ENV = os.path.expanduser("~/.hermes/.env")
INBOX = "coordination@agentmail.to"


def get_key():
    try:
        with open(ENV) as f:
            for line in f:
                if line.startswith("AGENTMAIL_API_KEY="):
                    return line.split("=", 1)[1].strip().strip('"').strip("'")
    except OSError:
        pass
    return None


def iso_to_ts(s):
    return datetime.fromisoformat(str(s).replace("Z", "+00:00")).timestamp()


key = get_key()
if not key:
    sys.exit("agentmail watchdog: no AGENTMAIL_API_KEY found")

url = "https://api.agentmail.to/v0/inboxes/" + INBOX + "/messages?limit=10"
req = urllib.request.Request(url, headers={"Authorization": "Bearer " + key})
try:
    with urllib.request.urlopen(req, timeout=20) as r:
        data = json.load(r)
except Exception as e:
    sys.exit("agentmail watchdog: fetch failed: %s" % e)

msgs = data.get("messages", [])
if not msgs:
    sys.exit(0)

newest_ts = max(iso_to_ts(m.get("timestamp", "")) for m in msgs)

last_ts = 0.0
if os.path.exists(STATE):
    try:
        with open(STATE) as f:
            last_ts = float(f.read().strip() or 0)
    except (OSError, ValueError):
        last_ts = 0.0

alerts = []
for m in sorted(msgs, key=lambda x: iso_to_ts(x.get("timestamp", ""))):
    ts = iso_to_ts(m.get("timestamp", ""))
    if ts > last_ts:
        subj = m.get("subject", "(no subject)")
        frm = m.get("from", "")
        prev = (m.get("preview") or "")[:400]
        alerts.append("📬 %s\nFrom: %s\nTime: %s\n%s" % (subj, frm, m.get("timestamp", ""), prev))

try:
    with open(STATE, "w") as f:
        f.write(str(newest_ts))
except OSError:
    pass

if alerts:
    print("\n\n".join(alerts))
