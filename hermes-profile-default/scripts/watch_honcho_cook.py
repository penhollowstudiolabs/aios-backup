#!/usr/bin/env python3
"""Ultra-light monitor: notify only when the Honcho Track B backlog drains (~0 pending, no stuck in-progress)."""
import json, time, urllib.request, sys

BASE = "http://localhost:8000/v3/workspaces/local/queue/status"
POLL = 300          # every 5 min
CONFIRM = 2         # 2 consecutive drained reads
timeout_sec = int(sys.argv[1]) if len(sys.argv) > 1 else 12*3600
start = time.time()
drained = 0

def status():
    try:
        with urllib.request.urlopen(BASE, timeout=10) as r:
            return json.loads(r.read())
    except Exception:
        return {}

while time.time() - start < timeout_sec:
    d = status()
    p = d.get("pending_work_units")
    inprog = d.get("in_progress_work_units")
    done = d.get("completed_work_units")
    # Consider done when pending==0 and in_progress==0 (fully caught up)
    if p is not None and p == 0 and inprog == 0:
        drained += 1
        if drained >= CONFIRM:
            print(f"TRACK_B_BACKLOG_DONE: completed={done} after {int(time.time()-start)}s")
            sys.exit(0)
    else:
        drained = 0
    time.sleep(POLL)

print(f"TRACK_B_MONITOR_TIMEOUT after {int(time.time()-start)}s")
sys.exit(2)
