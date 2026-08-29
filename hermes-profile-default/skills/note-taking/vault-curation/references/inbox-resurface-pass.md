# Inbox resurface pass (intended-work → workspace)

Captures the 2026-08-29 resurface-pass technique. Avi's recurring pain: inbox
items "wanted to start" never resurface into active work — captured but never
reaches the workspace. This is a class of curation work (not a one-off) and
should be repeated.

## The core realization

The disease is **no mechanism turns a captured intent into a surfaced workspace
action** — not "lost files." A captured "I want to start X" sitting in `_Inbox`
may as well not exist. So the fix is a *resurfacing* workflow plus a recurring
mechanism, not just re-filing.

## Classification scheme (one bucket per item)

- **INTENDED-WORK** — forward-looking intent to start/build/do/act. Signals:
  "I want to", "let's build", "should we", "next step", "for later", "proposal",
  "future", "todo". Flag whether any completion evidence exists (default: none).
  Do NOT classify as intended-work on invention — only if content actually
  expresses forward intent.
- **COMPLETED-RECORD** — report/log/decision record of something already done
  ("RESOLVED", "Complete", build record, deployment verification).
- **REFERENCE** — deep-capture / knowledge / transcript / reading material;
  informational, not an action.
- **DUPLICATE-STALE** — redundant/obsolete (e.g. `.bak` copies of a live handoff).

## Running the scan

- **Large inbox → delegate.** A subagent reads every top-level `.md` (skip
  subfolders like `ChatExport_*`, `*_Intake`, `Web Clips`, and non-md files),
  classifies each, and returns the INTENDED-WORK list + "top N most actionable".
  This avoids flooding the parent's context with 100+ reads. Pass the exact
  output format in the delegation context (see below).
- **Verify surfaced items are truly absent from the workspace.** Grep the
  workboard / `Re-Entry.md` / two-week priorities for each top pick. A top pick
  already tracked (or only cited as an "accepted fact record" without pending-
  action status) is not really lost — say so rather than overstating.
- **Present, then let Avi choose.** Do not wire jobs or move files without his
  explicit decision. Offer: wire a recurring resurfacing job, promote the top
  picks to the workboard now, or pause for his review of the full list.

## Recommended recurring mechanism

One scheduled job that periodically scans `_Inbox`, flags newly-arrived
intended-work, and surfaces it onto the workboard / daily brief — so "wanted to
start" items stop vanishing. A one-time scan fixes today's backlog but not the
system; propose the recurring job as the durable fix.

## Useful delegation context template

```
You are running a resurface pass on Avi Penhollow's vault inbox at
/root/vault/Atlas/_Inbox/. Classify every top-level .md file into
INTENDED-WORK / COMPLETED-RECORD / REFERENCE / DUPLICATE-STALE. For each
INTENDED-WORK item list: exact filename + 1-line summary of what Avi wanted
to start + any completion evidence. Flag the top 3 most actionable. Report
counts; totals must equal files read. Be evidence-based — do not invent
intent. Read every top-level .md; skip subfolders and non-md files.
```
