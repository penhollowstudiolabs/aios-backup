# As-built description mode (read-only system audit)

When Avi (or an external reasoning model he's using) asks for a description of
the AIOS/vault **as it actually exists today — not recommendations, not a
redesign**, this is the mode. The deliverable is an honest current-state report
including defects. You change nothing.

## The framing Avi sets, and what it means

- "As-built, not how it should work" → describe reality, suppress the urge to
  propose fixes. If he says "do not propose fixes yet," a fixes section is a
  failure even if the fixes are good.
- "Cite the actual vault path or filename" → every structural claim names a real
  path you verified, e.g. `AIOS/Current Workboard.md`, not "the work board."
- "Treat your own prior understanding as something to verify against the vault"
  → do NOT answer from memory, your self-description, or the Re-Entry card's
  prose. Open the files. Memory is a hypothesis; the disk is the evidence.
- "If something is unclear even to you, say so explicitly" → a dedicated
  "what I'm unsure of" section is expected, not a weakness. Name what you could
  not verify and why.

## Method that worked (2026-09-05 full-vault pass)

1. Load `vault-curation` + `obsidian` skills for path conventions; vault is
   `/root/vault`.
2. Survey structure first: `find . -maxdepth 2 -type d` and a top-level `ls -la`.
   Note anything that looks duplicated or stray before reading contents.
3. Read the navigators in parallel and in full: `AIOS/Current Workboard.md`,
   `AIOS/Re-Entry.md`, `AIOS/Vault Map.md`, `AIOS/Current Priorities - Two-Week
   Focus.md`, `AIOS/Alyosha/{Operating Notes,Self-Orientation,README}.md`,
   `Workboard Archive`, the governing standing rules in
   `Efforts/Captain-Avi-System/`, and the `aios-operating-conventions` skill.
4. Cross-check docs against disk, don't trust the doc. For each structural claim
   a navigator makes, verify it: `mtime` of the folder it points to, whether the
   folder is empty, whether a duplicate exists elsewhere.
5. Verify crons against the live store, not the tool. The `cronjob` tool and the
   live profile's `jobs.json` can name the same job with different schedules.
   Read `/root/.hermes/profiles/<live-profile>/cron/jobs.json` AND
   `/root/.hermes/cron/jobs.json`; compare enabled/schedule/run-count. The store
   with the high `repeat.completed` count is the one actually firing.
6. Cover every requested bullet with a real path; where you can't verify, say so.
7. Save the report into the vault as a dated `AIOS/` note and confirm `ob-sync`
   will carry it. Deliver the full text in-channel too.

## Inconsistency classes to check every time (found real on 2026-09-05)

This doubles as an audit checklist — these are the recurring failure modes of
*this* vault, so look for them specifically on any future as-built pass:

- **Two disagreeing cron stores** — tool reads root `default`; runtime is a named
  profile. Same job, different schedule. Confirm which store fires.
- **A referenced scheduled deliverable with no backing cron** — e.g. the "5:30 AM
  daily brief" is cited across memory/prompts but no job produces it and the
  output folder (`Calendar/Daily Briefs/`) had gone stale. Never report a brief
  as "running" without a cron + fresh output to back it.
- **Duplicate top-level vs `Atlas/` folders** — `Business/`, `Domain-Knowledge/`,
  `People/`, `Legal-and-Compliance/`, `Infrastructure/`, root `_Inbox/` exist
  both at vault root (stale/empty) and under `Atlas/` (live). Half-finished
  consolidation. Check mtimes both sides before calling either dead.
- **Stale navigator that reads as current** — `Vault Map.md` naming Efforts
  folders that no longer hold the live work; `Re-Entry.md` whose body is a weeks-
  old checkpoint with newer blocks stacked on top. Report the staleness, don't
  silently trust the top block.
- **A doc marked NOT AUTHORIZED still living in an active folder** — e.g.
  `Efforts/SPED-Workflow/SPED-Command-Center.md`. Flag it; a fresh agent could
  mistake it for canon.
- **Doubled Efforts naming** — `SPED-Workflow` (live) vs `Special-Ed-Caseload`
  (empty shell); `Ilocos-Adarna-Business` (live) vs `Ilocos-Emporium` +
  `Adarna-Plant-Co`.
- **Misleadingly-named backup** — `aios-daily-backup.sh` backs up `/root/.hermes`,
  NOT `/root/vault`; the vault's durability is Obsidian Sync, not that cron.
- **Loose junk at vault root** — empty `Untitled*.md`, capture-test debris,
  doubled `.md.md` extensions.

## Pitfalls

- Don't let the report drift into recommendations when he asked for as-built.
- Don't cite a navigator's claim as fact; cite the disk. The navigators are
  themselves among the things being audited.
- Don't smooth over a contradiction to make the system look coherent — the
  contradictions ARE the finding.
