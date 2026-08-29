---
name: vault-curation
description: Use for Avi's vault-curation sessions.
version: 1.0.0
metadata:
  hermes:
    tags: [vault, curation, inbox, obsidian, atlas, efforts]
---

# Vault Curation Sessions

Recurring protected cadence (Avi's "vault work" sessions). Goal is NOT to reorganize
everything — it is to stop personal ideas from being "lost to the ether" in
`Atlas/_Inbox` and to surface what Avi left behind, while respecting that moves are
gated on his explicit choice. See `references/obsidian-headless-sync.md` for the
diagnostic when expected files don't appear in the vault.

## Trigger

- Avi says "let's look at the vault work" / "vault curation" / "things I left behind"
  (or references a scheduled/protected vault-curation block that was skipped).
- Any scan intended to file/archive/organize inbox content rather than merely read it.

## Avi's working preferences (learned, non-negotiable)

- **Eyeball before moving.** Read each candidate note before filing it anywhere.
  Never file blind off a filename or a triage report alone.
- **Decision gate:** present buckets + a clear verdict per item, then let Avi choose
  scope (which items, where they go, whether to act). Evidence-first: do not claim a
  file is present/moved until verified on disk. "Verified present" from another agent
  or device is a claim, not proof — confirm locally before acting.
- **Bucket by lane, not by effort.** Skein the inbox into distinct buckets
  (personal ideas, creative/essay threads, operational records, raw non-md intakes,
  deep-capture/reference notes) and surface counters so nothing swims past.
- **File keepers into a home, not a flat pile.** Create/use a lane (e.g. `Atlas/Ideas/`)
  for idea captures; keep creative/essay threads (e.g. Beloit-data-center + its full
  trajectory) together and **link the pair reciprocally** with index headers.
- **Delete only double-confirmed duplicates.** And only when the duplicate itself
  designates its own disposal (e.g. a "Prefer the other note; this can be discarded"
  block) and the canonical twin + source artifact remain. Otherwise leave it.
- **Nothing else in the vault changes.** Per-task authorization only. Do not touch
  files named in a different authorization (e.g. an `SPED-Command-Center.md` marked
  NOT AUTHORIZED) even during a curation session.
- Status/authority markers in note content matter (e.g. FLAGGED / ACTIVE direction /
  NOT authorized) — fold them into the verdict rather than treating the note uniformly.

## Workflow

1. **Resolve the vault path.** Vault lives at `/root/vault` (VPS2/Alyosha). Use
   absolute paths.
2. **Establish live state** before acting: count inbox items (md vs non-md),
   list subfolders, note newest-first files. Use `search_files(target:"files")`
   for filenames, `read_file` for content.
3. **Identify the scheduled work.** Check `AIOS/` operating notes / workboard /
   `Re-Entry.md` for what the curation block was meant to cover (e.g. a one-time
   "first protected session"; mechanical triage may already be parked in
   `AIOS/Dewey/Plans/`).
4. **Bucket + scan.** Surface buckets with live counters, then read the candidate
   idea captures. For each, produce a short verdict: keeper / creative-thread /
   idea-not-authorized / done-obsolete / duplicate.
5. **Present to Avi** with a recommended scope. Let him pick depth. Common options:
   review shortlist, file 1–3 by lane, consolidate duplicates, or design a new lane.
6. **Execute his choice:** mkdir lane → `mv` keepers → add reciprocal index-header
   links on paired notes → delete only double-confirmed dups. Keep intact anything
   not in his scope.
7. **Report:** listed final paths, the pair linked, what was deleted and why, and
   what was deliberately left untouched (with reasons).

## Pitfalls

- **Don't over-engineer structure.** Avi prefers actions that produce visible
  outcomes now over elaborate reorganization. One new lane + real moves beats a
  redesign. (Source: Two-Week Focus guiding rule — "a system that supports a few
  real actions now is better than a sophisticated system that postpones them.")
- **Don't infer from docs; verify live.** Same discipline as other Avi work —
  confirm counts, dates, and on-disk presence with tools before stating them.
- **`Atlas/Ideaverse/` is a reflective journal** (Co-dreamer/Thirumeni), not the
  home for standalone idea captures. Use a separate `Atlas/Ideas/`-style lane.
- **Duplicate consolidation is the riskiest move.** Only delete when the target note
  explicitly names a preferred twin and the source artifact (e.g. PDF) survives.
- **Avoid deferring every move.** If Avi picked a scope, execute it; don't bounce it
  back with more options unless the decision genuinely changes the file targets.