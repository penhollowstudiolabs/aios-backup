#!/usr/bin/env python3
"""Reusable AgentMail sender (Avi-directed sends). Reads subject + body file.

Usage:
  agentmail_send.py <to_inbox> <subject> <body_file> [--cc avipenhollow@gmail.com]

Key loaded from .env (AGENTMAIL_API_KEY), never echoed. Sends FROM coordination.
"""
import json, os, sys, urllib.request

def load_key():
    with open("/root/.hermes/profiles/alyosha/.env") as f:
        for line in f:
            line = line.strip()
            if line.startswith("AGENTMAIL_API_KEY="):
                return line.split("=", 1)[1]
    raise SystemExit("ERR: AGENTMAIL_API_KEY not found")

def main():
    if len(sys.argv) < 4:
        raise SystemExit("usage: agentmail_send.py <to> <subject> <body_file> [--cc addr]")
    to = sys.argv[1]
    subject = sys.argv[2]
    with open(sys.argv[3]) as f:
        text = f.read()
    cc = []
    if "--cc" in sys.argv:
        i = sys.argv.index("--cc")
        if i + 1 < len(sys.argv):
            cc = [sys.argv[i + 1]]
    KEY = load_key().strip().strip('"').strip("'")
    API = "https://api.agentmail.to/v0"
    payload = {"to": [to], "subject": subject, "text": text}
    if cc:
        payload["cc"] = cc
    req = urllib.request.Request(
        f"{API}/inboxes/coordination@agentmail.to/messages/send",
        data=json.dumps(payload).encode(),
        headers={"Authorization": f"Bearer {KEY}", "Content-Type": "application/json"},
        method="POST")
    with urllib.request.urlopen(req, timeout=60) as resp:
        print("SENT", json.dumps(json.loads(resp.read().decode())))

if __name__ == "__main__":
    main()
