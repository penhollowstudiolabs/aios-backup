---
name: agent-handoff-protocol
description: Use when handing work between agents. Preserve evidence.
version: 1.0.0
created_by: agent
---

# Agent Handoff Protocol

Use when one agent has the context and another agent has the cheaper or uniquely capable execution environment—especially VPS ↔ laptop handoffs.

## Principle

Use a **handoff**, not remote control. The origin agent scopes the work and validates the returned artifact. The target agent works only in its own authorized environment. Do not expose laptop-local services, credentials, or browser sessions across the network merely to avoid a handoff.

## Choose the target lane

- **Dewey / laptop-local:** deterministic document work, OCR/rendering, local JSON manipulation, bounded local-model exception triage, or files/tools that exist only on the laptop.
- **Hollow / laptop:** browser/UI verification, authorized laptop files, social/content work, and local operational actions in Hollow’s scope.
- **VPS agent:** continuity, commerce operations, vault reconciliation, scheduled work, APIs available in that host’s approved scope.
- **Ephemeral subagent:** self-contained research, inspection, parsing, or parallel reasoning without machine-specific access. Do not use it for durable work or tasks requiring interaction.

## Before creating a handoff

1. Confirm the target has a real capability advantage; do not delegate merely to move work around.
2. Check whether the work could be done deterministically before involving any model.
3. Separate the requested task from implied execution. If a user is trying to remember an operating procedure, locate the authoritative record first; do not substitute a related but different workflow.
4. State data sensitivity. Do not place secrets, buyer/customer PII, or student PII in a handoff return artifact.
5. Set the side-effect boundary explicitly: inspection only, or the exact authorized write.

## Handoff-card format

Write a compact card in `Atlas/_Inbox` unless Avi gives a different destination.

```markdown
---
type: agent-handoff-card
status: ready-for-<target>
origin: <agent>
target: <agent>
priority: <normal|urgent>
sensitivity: <classification>
side_effects: <prohibited|exact scope>
---

# <Task>

## Purpose
<Why this target is needed.>

## Task
<Specific inputs and acceptance criteria.>

## No-action boundary
<Forbidden writes, messages, live executions, credentials, or external changes.>

## Return artifact
<Create exactly one named report/artifact at this path.>

## Required return
1. What was actually done
2. Exact artifact path/output
3. Verification performed
4. Uncertainty, mismatch, or blocker
5. Whether any external state changed
```

Keep a no-side-effect pilot narrow: static inspection of a real script, deterministic conversion/rendering, or structured extraction. Do not begin with a live import, deployment, message send, or cross-host service exposure.

## Return and reconciliation

1. Target returns the promised artifact—not only a chat claim.
2. Origin reads it and compares it to the relevant source record or acceptance criteria.
3. Origin reports only verified conclusions to Avi.
4. Preserve the originating data/procedure separately from the handoff report; a handoff report is evidence about execution, not automatically the canonical operating procedure.
5. Promote or reconcile only after Avi’s decision where the result affects live operations.

## Pitfalls

- Do not infer that a report is absent only because it is not in `Atlas/_Inbox`; search the whole vault and account for after-midnight filenames.
- Do not claim an agent has completed a task until the exact return artifact is read.
- Do not call a related inventory/physical-entry workflow the requested retroactive-sales procedure. Trace the specific importer, export contract, status mapping, and execution boundary.
- Do not allow local-model output to invent fields, statuses, or code behavior. Require code/location or source-document evidence.
- Do not make a laptop’s localhost-only service remotely reachable simply to enable collaboration.

## Escalation

If the same handoff shape recurs and manual routing is becoming the bottleneck, propose a durable Hermes Kanban board. Do not introduce it merely for a single pilot; prove the card-and-return loop first.
