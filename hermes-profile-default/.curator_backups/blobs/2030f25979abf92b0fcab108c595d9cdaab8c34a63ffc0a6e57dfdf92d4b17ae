# Worked Example — 2026-08-30 Memory Architecture Council

A full async council that produced a durable, scope-guarded decision record. Use as a template for structure, boundaries, and the decision-record shape.

## Record path
`AIOS/Memory-Architecture/2026-08-30 - Memory Architecture Council - Decisions.md`
(backlinked from `AIOS/Re-Entry.md` and `AIOS/Current Workboard.md`).

## Re-entry source
`Atlas/_Inbox/2026-08-30 - AIOS Memory Architecture Council - Session Re-entry Packet.md` — today's meeting source; the earlier Phase 1 evidence handoff is historical context.

## The eight decisions (shape)
1. **Four-layer map — approved:** vault authority → re-entry orientation → Track A cited retrieval → optional Track B modeling.
2. **Track A — pilot candidate only, NOT authorized to build.** Rejected: Hindsight (slow, strips citations), Holographic (not semantic), Honcho (wrong tool for vault retrieval). Implementation stays un-built until Avi separately authorizes.
3. **Track A boundaries — locked.** Roles: Dewey=design author, Alyosha=sole initial operator, Avi=decision authority+corpus approver, Hollow=privacy/provenance reviewer. CLI-only, no HTTP; manual rebuild; synthetic probe only; hard exclusions (Personal-Finances, Legal-and-Compliance, People); allowlist; FTS5 fallback; explicit low-confidence behavior; logged acceptance metrics.
4. **Track B — live bench confirmed, not granted.** Stood up by Alyosha under Avi's step-by-step approval in a parallel session; council confirms terms + Sep 4 gate, does not authorize the build. Data treatment at gate = retain-then-review (Avi option 2).
5. **Shared aios budget — locked.** Track B loopback 5432/6379/8000 + in-network honcho-ollama (~1GB+); Track A SQLite-only, no port. Host Ollama (127.0.0.1:11434) SEPARATE from honcho-ollama — non-negotiable, never collapsed. All ports loopback-only; `prime-lab` never disturbed.
6. **Honcho provenance/correction — locked.** Output = hypotheses about Avi, not settled fact; cross-check before acting; Avi can correct, corrections recorded so not re-derived; source-linked; correction wins over model output; never silently overwrite vault truth.
7. **Cross-agent sharing — none now, none inferred.** Any future sharing needs a separate council decision with explicit provenance + consent.
8. **Canonical record — set.** Path above. Keeper=Alyosha, approver=Avi, reviewer=Hollow. Scope-guarded: canonical for this council only, linked to (not superseding) 8/22 REENTRY-CHECKPOINT.

## Real techniques that worked
- **Live-state verification:** ran read-only `ss -tlnp`, `docker ps -a`, `free -h`, `df -h` to catch that Honcho was ALREADY running (containers created 12:31–13:07 that day) even though the packet said "not installed." Flagged the contradiction to Avi rather than locking a false premise. The attribution ("Alyosha stood it up") was from a parallel session — verify via container creation times, not assumption.
- **Verified rollback evidence:** Dewey provided pre/post SHA-256 hash match on `config.yaml` + `USER.md`, `memory.provider` never set, MEMORY.md diff explained as a normal post-rollback write. Keep the honest scope: file-state rollback proven ≠ no network egress (no packet trace).
- **Relay attribution:** when an agent has no inbox (Dewey), Avi relays their text verbatim. Treat it as authoritative user-delivered input.

## Relay-round shape used
1. Alyosha opens with a full verification of all settled items against the canonical record (gives everyone the same baseline).
2. Hollow responds; Alyosha responds to Hollow separately, folding in edits + flagging any new Avi decision needed (Track B data treatment).
3. Dewey responds (initial, hadn't seen replies); Alyosha responds to Dewey separately.
4. Avi decides the open item; Alyosha writes the decision record.
5. Council moved to AgentMail: send from `coordination@agentmail.to` to `coordination@`+`system-alerts@`, cc `avipenhollow@gmail.com`.

## Session note
Only Avi, Alyosha, and Hollow respond in the primary "Captain Avi Team AI" Telegram group; Dewey is reached via Avi's relay (his Hermes config was being checked at the time).
