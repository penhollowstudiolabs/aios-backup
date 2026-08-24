---
name: agent-work-handoffs
description: Use when agents hand off bounded work across machines.
version: 1.0.0
author: Alyosha
created_by: agent
---

# Agent Work Handoffs

Use when a VPS agent, laptop agent, or subagent needs another agent to perform a bounded task efficiently—especially when the target has local tools, local files, browser access, or a lower-cost execution path.

## Purpose

Use a human-visible, artifact-based handoff rather than informal claims of completion or direct cross-machine tool control. The originating agent remains responsible for scope, reconciliation, and the user-facing conclusion.

## Default workflow

1. **Choose the cheapest capable lane.**
   - Laptop agent: local/offline tools, local files/UI, deterministic processing, bounded small-model work.
   - VPS agent: shared-vault context, durable reconciliation, server-local tasks.
   - Ephemeral subagent: contained research, inspection, or parallel reasoning without special machine access.
2. **Write one handoff card** in `Atlas/_Inbox` before dispatching. The card must name the target, task, evidence, return artifact, and boundaries.
3. **Dispatch explicitly.** A vault card is a brief, not a queue or a start signal. Send the target the exact card path or a direct task message.
4. **Require one return artifact** in `Atlas/_Inbox` with evidence, not a vague chat-level “done.”
5. **Reconcile before relying on it.** The originating agent reads the return, checks it against the contract/source records, and reports a clear ready/caveat/blocked result.
6. **Only then** propose a live write or consequential next action; preserve Avi’s approval gate.

## Required handoff-card fields

- target agent and originating agent;
- precise task and source/artifact paths;
- expected output path and report shape;
- sensitivity boundaries;
- explicit **no-action** constraints (e.g., no live run, no code edit, no messages, no external change);
- verification required;
- evidence context / governing record;
- stop condition.

Use `templates/handoff-card.md`.

## Return-artifact standard

Require these five points:

1. What was actually done.
2. Exact artifact path/output and code or source-location evidence where relevant.
3. Verification performed and result.
4. Uncertainty, mismatch, or blocker.
5. Whether any external state changed.

## Static-review pattern

For an upcoming live write, first use a static, no-side-effect review against the approved contract. It is valuable when it can catch an implementation mismatch before production data changes. The return must mark each contract item **confirmed**, **not found**, or **unclear** and cite precise code/source locations.

## Pitfalls

- Do not treat the shared vault as an automatic dispatcher; task start must be explicit.
- Do not expose a laptop-local service merely to simplify a handoff. Preserve local binding unless Avi explicitly approves a networked design.
- Do not infer a live implementation matches a documented plan; inspect the actual source or target environment.
- Do not let the target quietly broaden scope, make edits, or perform external actions.
- Do not claim a handoff succeeded until the return artifact is present and reconciled.
- Do not create a queue/Kanban system before the manual card → dispatch → artifact → reconciliation loop has proven useful repeatedly.

## Evidence record

The first verified pilot is summarized in `references/populate-from-sales-static-review.md`.
