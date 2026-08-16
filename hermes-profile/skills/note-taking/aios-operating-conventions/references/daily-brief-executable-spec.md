# Daily Brief — the cron prompt is the executable spec

**REVIEWING A DELIVERED BRIEF (8/15) — snapshot vs. error.** When Avi asks you to go through the brief and find errors, distinguish these sharply:
- **NOT an error:** a line that was ACCURATE when the brief was written (that morning) but is now stale because later work changed the state. E.g. today the brief said "Google token dead, day two" and "Nous figure missing" — both true at 5:30am, both resolved by our 8/15 afternoon work. Avi corrected me for calling these "errors": they're a point-in-time snapshot, not a mistake. Do not flag as errors; note they're now-superseded by later work, or leave them (the brief is historical).
- **A real error:** something that was factually wrong AT WRITE TIME — e.g. a weekday/date mismatch. Today's real one: "First day of school is Monday, August 18" but 8/18 is actually a TUESDAY (8/17 is Monday, the PD day). **Always verify weekday↔date pairs against the actual calendar** before trusting them — this is the recurring class of genuine error in a schedule-heavy brief.
- Don't mark Buzz-scheduled-today or other *current-schedule* items as errors just because a conversation pulled you elsewhere; they're the plan, not a mistake.

**REVIEW-PASS PROTOCOL (8/12):** Hollow critiques the delivered brief and emails
his review DIRECTLY to Alyosha via the AgentMail coordination lane (same as other
process-check loops — Avi is not the courier). Alyosha reads it, sorts each item
(hit / contestable / miss), responds to Hollow with counterpoints, and reports the
converged result to Avi — Avi stays the referee between the two. First pass 8/12:
Hollow's freshness catch (Nvidia/AMD 15% was an FT story from Aug 2025, Amazon
Agent Policy from Mar 2026 — carried as current) was a correct hit; improved the
scan-to-brief fold. Folds to fix: age labels on every Watch item, one source per
material claim, no stale carry-forwards, freshness cross-check step in the scan
prompt.

**FUTURE DIRECTION (8/12):** after the Power & Tech Watch lane shipped, Avi
said the brief "is looking great" and would "most likely" want to see it as an
**email, or even an HTML template** — *in the future*. NOT built yet; this is a
parked forward-looking preference. When revisited: HTML email template for the
brief (works whether read on screen or more formally than Telegram), possibly
with the Power & Tech Watch as a richer rendered section. Current delivery stays
Telegram voice/text until Avi says otherwise.


**POWER & TECH WATCH LANE LIVE 8/11 (Avi's main added section):** Avi is actively
tracking AI power + tech-oligarch dynamics and wants it in the brief. A separate
overnight scan job `power-tech-watch-scan` (`e78cdf4f5981`, runs 3:00 AM PDT =
`0 10 * * *` UTC, toolsets web+file, deliver=local) does the full-scope web sweep
and writes a dated file to `Calendar/Power-Tech-Watch/<date>.md`. The Daily Brief
folds the most recent scan file in as the #4 section. Voice per Avi: **critical
but objective** — treat claims from BOTH the administration AND the tech oligarchs
as self-interested until sourced; report material fact + sharp skeptical read; NO
hard cap on items; quiet-when-clean. Sourcing is Alyosha's call; cite primary
sources. Avi listens to the brief as AUDIO in the car, so ALL sections must read
aloud cleanly (short sentences, bold labels + bullets, no tables, links on their
own "Source:" line). Web works fine for Alyosha — Hollow is only the fallback if
this lane ever gets fragile.


**SPINE LIVE 8/10 evening (first run 8/11 5:30 AM PDT):** the cron prompt was
rewritten to be calendar-grounded per Avi's four answers: (1) calendars =
work mirror + primary + family; (2) caseload due-date pressure allowed but
brief only flags it briefly — the work dashboard bears the brunt; (3) the
5-element minimum design folded in; (4) gentle tap included occasionally.
Schedule data is read from `Efforts/SPED-Workflow/UHS-Schedule/`
(`fall_2026_operational_schedule.csv` + `bell_schedule_templates.json`).
Meeting-window projection remains OUT (negative availability only). The
prompt itself is the source of truth — edit via cronjob tool, not just this doc.

Live state (8/10): daily brief is cron job `a85b2d174ce5` ("Daily Brief"),
schedule `30 12 * * *` = **5:30 AM PDT**, delivers to Telegram chat
8743718071, models `deepseek/deepseek-v4-flash-0731` via nous. Outputs are
written to `~/.hermes/profiles/alyosha/cron/output/a85b2d174ce5/<ts>.md` and
the delivered brief is also archived in the vault at
`Calendar/Daily Briefs/`. Job details live in
`~/.hermes/profiles/alyosha/cron/jobs.json`.

## The core lesson (8/10)

**The thing that actually runs the brief is the cron job's `prompt` field — not
any spec document.** Avi repeatedly asked across sessions ("add this to the
brief," "I want to add that"), and those asks were being written into spec docs
(`Avi Operating Model - v1`, `AIOS/Current Workboard.md`,
`AIOS/Current Priorities`) — but the cron prompt was **never updated**. So the
vault said one thing and the delivered brief did another. Root failure mode:
treating the spec as the source of truth when the *prompt* is.

Rule: **when Avi asks to add/change the brief, edit the cron job's prompt (via
`hermes cron update` / the cronjob tool) in the same pass — not just the spec.**
Spec docs are design intent; the prompt is the running behavior.

## Minimum briefing design (from Avi Operating Model v1)

The intended daily orientation should contain ONLY:
1. top active commitments;
2. deadlines, appointments, and waiting-on items;
3. **changes or decisions needing Avi's attention**;
4. one recommended next action; and
5. a system-health exception **only when it materially matters**.

**"If nothing needs attention, say so plainly. Do not manufacture activity."** —
this is Avi's own line. A brief that always manufactures urgency is off-spec.

## Compilation-surface role (workboard wording)

"Treat the future daily brief as the intended compilation surface: stable
orientation, only material scheduled-task outputs, one source-linked
patterns-and-connections." It should **cross-link patterns from scheduled-task
outputs**, not just push a vault digest.

## The gentle tap on the shoulder (from the Ideaverse note, 8/05)

The brief may from time to time resurface **one past vibe-chat moment** as a
calm *memory* — reminding Avi of a thread born in the Ideaverse without pushing
it onto the workboard. Not an auto-export (the affirmation firewall still
governs exports). The first brief delivered this tap (8/05); later runs dropped
it.

## Calendar / meeting-protection layer (STATUS 8/10 EVENING: foundation BUILT, spine pending)

An operating-model distinction: a briefing gives orientation but does NOT
prevent missed meetings. Meeting protection needs (a) a confirmed authoritative
calendar source, (b) dependable alerts on the device Avi uses, and (c) visible
follow-through for captured-but-incomplete tasks.

**The dependency cleared 8/08:** Gmail + Google Calendar OAuth for the alyosha
profile is live and read-only verified
(`~/.hermes/profiles/alyosha/google_token.json`).

**The foundation was BUILT 8/10 (Hollow, with Avi; verified by Alyosha live):**
- UHS command-center layer exists (laptop project `UHS Case Management Command Center`); curation note: `Efforts/SPED-Workflow/2026-08-10 - UHS Case Management Command Center - Handoff Curation.md`.
- Unified Google read surface verified: Outlook→Google import mirror alive; primary calendar cleaned (old recurring UHS series removed, 17 exact PLC/DM/SM meetings added, 25 transparent non-blocking exceptions).
- **Runtime schedule data is now vault-side** at `Efforts/SPED-Workflow/UHS-Schedule/` (`fall_2026_operational_schedule.csv` + `bell_schedule_templates.json`, approved 8/10) — the 5:30am brief can read day-type/bell pattern with the laptop off. Source roles: school Google Drive = authoritative; laptop project = active implementation; vault copies = always-on runtime/read layer; Google context entries = display layer, not the sole database. Do NOT rebuild calendar logic.

**Spine build (calendar-grounded brief) pending Avi's answers to four questions (Alyosha's leans included):**
1. Which calendars feed the brief? (lean: work import mirror + primary + Family; skip Holidays/Proximity Hub/Kathleen's)
2. Mirror privacy-safe caseload due-dates vault-side (case codes + dates only) for "approaching pressure" reporting? (lean: yes — same pattern as schedule files)
3. Upgrade to the 5-element minimum design in the same pass? (lean: yes)
4. Include the gentle tap occasionally? (lean: yes)

Current prompt (8/10) is a vault-digest with stale context (e.g. "Amazon ships to FBA Monday" was 8/10) — refresh context when rebuilding. Enabled toolsets: file+terminal (Google reads go through the google-workspace skill CLI / direct API).

## The gap in one line

The brief is a working **report**, but the **system** it was designed to become
(calendar-grounded, meeting-protecting, cross-linking scheduled outputs) is now
foundation-built and waiting on Avi's four spine decisions above. When
rebuilding: fold the full accumulated design into the cron prompt, get Avi's
sign-off, update the prompt — and refresh stale context.