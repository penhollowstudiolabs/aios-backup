---
type: agent-handoff-card
status: ready-for-dispatch
created: YYYY-MM-DD
origin: <originating agent>
target: <target agent>
priority: normal
sensitivity: <classification>
side_effects: prohibited
---

# <Task name>

## Task
<State the precise bounded task and source paths.>

## Evidence context
- `<governing record path>`

## No-action boundary
- Do not execute live writes, edit source, send messages, publish, or broaden scope.

## Return artifact
Create exactly one report in `Atlas/_Inbox` at:
`YYYY-MM-DD - <Target> - <Task> Report.md`

Report:
1. what was actually done;
2. exact paths/output and source-location evidence;
3. verification performed;
4. uncertainty or blockers;
5. whether external state changed.

## Stop condition
<What ends this task.>
