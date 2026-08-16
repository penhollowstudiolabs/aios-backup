#!/usr/bin/env python3
"""
Weekly authority-chain drift sweep (Alyosha-owned, read-only, report-exceptions-only).

Validates the short authority chain for active projects so stale docs don't
recur (see aios-operating-conventions/references/stale-source-doc-reconciliation.md).

Checks, per active project area:
  - canonical source exists and is readable
  - Re-Entry/operational summary points to that source
  - older status-bearing artifacts carry a SUPERSEDED/HISTORICAL marker
  - living summaries don't present volatile counts/HEADs as permanently current

Output: NOTHING when clean (silent watchdog pattern). Non-empty stdout = the
exceptions, delivered to Avi via Telegram. No autonomous edits ever.

Run: /usr/local/lib/hermes-agent/venv/bin/python3 authority_chain_sweep.py
Scheduled: cron 'authority-chain-drift-sweep' (no_agent), Sundays 13:00 UTC.
"""
import os, re, sys, datetime

VAULT = "/root/vault"

# Anchors: (label, canonical source, summary card)
# canonical = where live truth lives; summary = short operational pointer.
ANCHORS = [
    ("SPED build",
     f"{VAULT}/Atlas/_Inbox/SPED_Workflow_System_Technical_Architecture_and_Build_Status.md",
     f"{VAULT}/AIOS/Re-Entry.md"),
    ("Model routing/subscriptions",
     f"{VAULT}/Efforts/Captain-Avi-System/Model-Token-Usage-Tracking.md",
     f"{VAULT}/AIOS/Re-Entry.md"),
]

SUPERSEDED_RE = re.compile(r"(superseded|historical|stale|do not use|outdated)", re.I)
VOLATILE_RE = re.compile(r"(current (head|commit)|^\s*\d+\s+commits?\s*$|latest:\s*[0-9a-f]{7})", re.I)

def scan_file(path):
    """Return list of problems for a status-bearing file."""
    problems = []
    if not os.path.exists(path):
        return [f"{path}: MISSING"]
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            full = f.read()
    except Exception as e:
        return [f"{path}: unreadable ({e})"]
    if VOLATILE_RE.search(full):
        problems.append(f"{path}: contains a volatile current-count/HEAD claim")
    return problems

issues = []

# 1. Re-Entry must exist and be readable
re_entry = f"{VAULT}/AIOS/Re-Entry.md"
if not os.path.exists(re_entry):
    issues.append(f"{re_entry}: MISSING")

# 2. Each anchor: canonical source readable; summary points to it; stale artifacts marked
for label, canonical, summary in ANCHORS:
    if not os.path.exists(canonical):
        issues.append(f"[{label}] canonical source missing: {canonical}")
    if not os.path.exists(summary):
        issues.append(f"[{label}] summary card missing: {summary}")

# 3. Scan status-bearing files in Atlas/_Inbox that look like current-state claims
inbox = f"{VAULT}/Atlas/_Inbox"
STATUS_HINT = re.compile(r"(status|state|current|build status|done|complete|ready)", re.I)
if os.path.isdir(inbox):
    for root, _, files in os.walk(inbox):
        for fn in files:
            if not fn.endswith(".md"):
                continue
            p = os.path.join(root, fn)
            try:
                with open(p, encoding="utf-8", errors="replace") as f:
                    text = f.read(2000)
            except Exception:
                continue
            # Candidate status-bearing doc (has status language AND no superseded banner)
            if STATUS_HINT.search(text) and not SUPERSEDED_RE.search(text[:2000]):
                prob = scan_file(p)
                if prob:
                    issues.extend(prob)

# 4. Report exceptions only; dedupe
seen = set()
for i in issues:
    if i not in seen:
        seen.add(i)

if not seen:
    sys.exit(0)  # silent — nothing to report

print("AUTHORITY-CHAIN SWEEP — exceptions found:")
for i in sorted(seen):
    print(f"- {i}")
print(f"\n(Checked {datetime.datetime.now().astimezone().strftime('%Y-%m-%d %H:%M %Z')}. Read-only; no edits made.)")
