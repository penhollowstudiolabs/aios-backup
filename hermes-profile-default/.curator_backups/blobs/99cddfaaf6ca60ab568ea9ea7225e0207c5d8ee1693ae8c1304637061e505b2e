---
name: scheduled-automation-operations
description: "Use when managing or explaining scheduled jobs."
version: 1.0.0
created_by: agent
---

# Scheduled Automation Operations

Use for cron/scheduled-job inventory, changes, deletion, and explanation. Preserve job intent and verify the scheduler's resulting state rather than trusting a write acknowledgment.

## Workflow

1. List jobs first. Identify jobs by both exact name and job ID. If the user repeats a name, confirm from the list whether it refers to one job or multiple jobs; do not remove a second job that is not present.
2. For a schedule update, first record every material setting from the listed job: name, schedule, delivery target, script or agent prompt, `no_agent`, skills, toolsets, workdir, repeat behavior, monitor/script settings, and enabled state.
3. Send an explicit update payload that preserves all of those settings while changing only the requested field. Do not assume omitted update fields are retained; some scheduler updates can clear or reset them.
4. Immediately list/read back the target job and verify: requested schedule, exact name, delivery, script/prompt mode, enabled state, and next run time.
5. For cancellation, remove only the confirmed job ID, then list again and verify its absence. State plainly that deletion is permanent.
6. For explanations, inspect the actual script or job prompt before describing behavior. Distinguish documented intent from implemented behavior. State whether it can modify data, its delivery behavior, and what silence versus output means.

## Time and Reporting

- Report schedules and next-run times in Avi's Pacific time.
- Be terse: name, change, verification, next run when useful.
- Never imply local/origin cron delivery will reach the CLI; local output remains scheduler-visible and origin is not a live CLI notification channel.

## Pitfalls

- A cron `run` action executes the real job, even when used to seek an explanation. Never manually run a job solely to learn what it does. Read its script or configured prompt instead.
- `no_agent=True` script jobs may intentionally emit no stdout when healthy. Treat a successful silent run as clean only after confirming the script follows an exceptions-only/silent-watchdog pattern.
- Do not infer that a script validates every behavior claimed in its comments. Read the control flow and report gaps between claims and actual checks.
