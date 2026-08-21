#!/usr/bin/env python3
"""Send a message on the AgentMail agent lane from aios.

Verified working 8/11. Fix the SUBJECT/BODY (and TO/CC if needed) below, then
run via execute_code + subprocess.run — NOT inline in terminal (the lifecycle
guard raises an 'embedded null byte' error on inline script runs).

Usage pattern:
    venv = "/usr/local/lib/hermes-agent/venv/bin/python3"
    r = subprocess.run([venv, "/root/.hermes/profiles/alyosha/skills/note-taking/aios-operating-conventions/scripts/send_agentmail.py"], ...)

Key from AGENTMAIL_API_KEY in the profile .env. Never echo the key.
"""
import json, os, urllib.request

def load_key():
    with open("/root/.hermes/profiles/alyosha/.env") as f:
        for line in f:
            line = line.strip()
            if line.startswith("AGENTMAIL_API_KEY="):
                return line.split("=", 1)[1]
    raise SystemExit("ERR: AGENTMAIL_API_KEY not found in .env")

KEY = load_key().strip().strip('"').strip("'")
API = "https://api.agentmail.to/v0"
FROM = "coordination@agentmail.to"   # inbox I send FROM
TO = ["system-alerts@agentmail.to"]  # Hollow's inbox
CC = ["avipenhollow@gmail.com"]       # Avi cc'd throughout agent discussions

# === EDIT THESE ===
SUBJECT = "Agent-lane message (Alyosha)"
BODY = "Body here."
# =================

def send(subject, text):
    payload = {"to": TO, "cc": CC, "subject": subject, "text": text}
    req = urllib.request.Request(
        f"{API}/inboxes/{FROM}/messages/send",   # inbox in path — bare /messages/send 404s
        data=json.dumps(payload).encode(),
        headers={"Authorization": f"Bearer {KEY}", "Content-Type": "application/json"},
        method="POST")
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read().decode())

if __name__ == "__main__":
    print("SENT", json.dumps(send(SUBJECT, BODY)))
