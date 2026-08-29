# Explicit-authorization filing: de-identification gate + on-disk confirmation

**Lesson 2026-08-28** — Avi authorized moving two SPED/IEP documents from
`Atlas/_Inbox/` into `Efforts/SPED-Workflow/` (Build Documentation + New Student
Intake Runbook, dated 2026-08-28).

## The failure mode it guards against
Sensitive-domain documents (SPED, IEP, FERPA, student records) must not be filed or
touched in a way that leaks restricted PII into the vault. Also, a file can be
"verified present" by the user or another agent while still not on this VPS's disk —
the Obsidian sync leg hadn't pulled it yet.

## The gate (apply when Avi authorizes moving named sensitive docs)
1. **Read every file in the authorization BEFORE moving it.** Do not file on filename
   or a triage report alone.
2. **Confirm de-identification.** Check the declared frontmatter
   (`privacy-line: DE-IDENTIFIED …`) AND scan the body for student names, accommodation
   content, or FERPA PII. Only file if it is genuinely process/structure/paths/metrics
   with no student-level material.
3. **Respect NOT-AUTHORIZED siblings.** If a sibling file (e.g.
   `SPED-Command-Center.md`) is marked NOT AUTHORIZED, do NOT wire new docs into it,
   edit it, or treat it as in-scope.
4. **Stay inside the exact scope.** File only the named files. Do not re-org, link,
   or edit anything else during that authorization. Rename is fine if it preserves the
   date prefix + title intent; never alter content.
5. **Confirm on-disk locally before acting.** Re-check `search_files`/`ls` for the
   file on this VPS. If not present, wait for sync / re-check — do not assume it
   landed because someone else said it did. Only move once actually on disk.

## What "done" looks like
Report the final paths, state that content was verified de-identified and unchanged,
name the NOT-AUTHORIZED file that was left untouched, and note the sync/on-disk
confirmation performed.
