# Workboard hygiene — keeping the re-entry card small and current

**Lesson 2026-08-28** — Avi: the Current Workboard "looks extremely messy" / "it is stale."

## The failure
`AIOS/Current Workboard.md` had accumulated completed migrations (Lane B, D, E), a
stale Patchi task still listed "awaiting steer" when the deliverable was deployed 3
days earlier, a completed Priority 1 still carrying open-todo text, and historical
header notes. It was 202 lines / 24.7KB — the opposite of a small re-entry card. It
also still asserted Obsidian/Syncthing was "retired" when `ob-sync.service` was live.

## The fix pattern (apply on curation/refresh)
1. **Keep the active board small.** It is a re-entry card, not a master task list.
2. **Archive completed/closed work to one pointer file** — `AIOS/Workboard Archive -
   Closed and Parked.md` — each entry a compact summary + source path. On the active
   board, replace the entry with a one-line pointer, e.g. `CLOSED 8/16 … full record
   in \`AIOS/Workboard Archive - Closed and Parked.md\``. Resolve to a pointer, not a
   wall of history.
3. **Refresh stale items from evidence, not memory.** A completed deliverable still
   marked "awaiting steer" must be marked COMPLETE only after verifying the
   completion (build record + live deployment), never on a guess.
4. **Verify live state before trusting the board's assertions.** This session the
   board claimed Obsidian/Syncthing "retired from VPS" while `systemctl is-active
   ob-sync.service` returned `active`. Confirm service/count/deploy state with tools.
5. **Lead with a short "Since <date> (latest first)" block** so re-entry reads current
   state before history, then list only genuinely open items.

## What moves to the archive (class)
- Completed migrations (Obsidian Sync closeout, Claude-project migration, publishing
  portfolio migration)
- Completed integrations (email/calendar OAuth)
- Completed/closed experiments (Patchi landing page)
- Resolved incidents and parked items (schedule reconciliation, OpenClaw gateway,
  DeepSeek pricing, aios SSH)

## Pitfall
Do not delete completed history outright — move it to the archive file (a pointer +
compact summary) so it remains recoverable. The active board gets the pointer; the
archive holds the detail.
