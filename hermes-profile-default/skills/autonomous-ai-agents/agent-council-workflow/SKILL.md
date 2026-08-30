---
name: agent-council-workflow
description: Use when Avi convenes a multi-agent council.
version: 1.0.0
author: Alyosha
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [council, multi-agent, decisions, relay, verification, records]
    related_skills: [operational-state-curation, agentmail-integration]
---

# Agent Council Workflow

Avi runs asynchronous cross-agent councils to align the fleet or settle a decision (e.g. post-rebuild alignment, memory-architecture). The pattern: agenda → async relay rounds → live-state verification → bounded decision record. **A council authorizes no implementation unless Avi separately approves it.**

## When to use
- "Quick Council", "Post-Rebuild Alignment", "[Domain] Council", or "Memory Architecture Council" requests.
- Any cross-agent decision that must be aligned across Alyosha, Hollow, Mayumi, Dewey, Avi before it takes effect.

## Core principles
1. **No implementation without separate authorization.** Approving a design direction ≠ authorizing the build. Say it explicitly in the record, e.g. "approved as pilot candidate only — NOT authorized to build." Never let a future reader mistake "approved" for "deployed."
2. **Verify before locking.** Cross-check live state (ports, processes, files, configs) with read-only checks rather than trusting stale summaries. If live state contradicts the packet, **stop and get Avi to reconcile** before locking affected decisions — do not paper over the contradiction.
3. **Keep provenance honest.** Distinguish "confirmed existing state" from "granted/authorized here." A council must not claim to authorize something that is already live (e.g. an already-approved bench). Correct your own records when they are stale.
4. **Scope-guard every record.** A decision record is canonical for its council only; link to (do not supersede) prior canonical records (e.g. the 8/22 REENTRY-CHECKPOINT). Keep multiple canonical records distinct and linked, not colliding.
5. **Don't accept false attribution about your own actions.** If a claim says you did X but you did not (in this session), correct it with evidence rather than accepting it silently.

## Async relay mechanics
- Councils are not synchronous; agents respond in relay rounds.
- **Open the round by verifying everything settled so far** against the canonical record — gives every agent the same baseline before they respond.
- Read each agent's response and **respond to each one separately** (not a merged reply).
- Then allow **one more round** for each agent to respond to that.
- When an agent can't join a channel (no inbox, broken config), **Avi relays** their input. Treat relayed content as authoritative user-delivered input, and keep the record's attribution accurate.

## Channel
- AgentMail is the async lane: send from `coordination@agentmail.to` to `coordination@` + `system-alerts@`, cc `avipenhollow@gmail.com`.
- Agents without an inbox (e.g. Dewey) are reached via Avi's relay. Only Avi, Alyosha, and Hollow respond in the primary Telegram group; Dewey's input arrives via Avi.

## Decision record
- **Durable path:** `AIOS/<Domain>/<YYYY-MM-DD> - <Name> - Decisions.md` — NOT `Atlas/_Inbox` (that is capture-only).
- **Roles:** record-keeper (Alyosha/continuity), approver (Avi), provenance reviewer (Hollow).
- **Backlink** from `AIOS/Re-Entry.md` and `AIOS/Current Workboard.md` so the record is discoverable.
- Preserve contradictions and unresolved evidence rather than silently normalizing them; flag what needs Avi's call.

## Pitfalls
- Distinguish **operational rollback** (stop a service / `docker compose down`) from **data treatment** (preserve vs. destroy volumes, derived data, test corpora). A council must set both; stopping containers is not data destruction.
- Verify **verification claims**: "file-state rollback proven" ≠ "no network egress" — keep separate, honest scopes.
- Record the executor/authority of anything already running (who stood it up, under what approval) or the decision record rests on a false premise.

## References
- `references/2026-08-30-memory-architecture-council.md` — worked example: four-layer map, Track A/B dispositions, shared-host budget, provenance contract, verification of live state.
