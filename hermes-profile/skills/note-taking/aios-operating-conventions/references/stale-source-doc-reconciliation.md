# Stale source-document reconciliation — preserve + supersede, never rewrite (8/15)

When a durable vault doc has drifted from live state, repair with **preserve +
supersede**, never silent rewriting. Case study: the July 23 SPED architecture
doc (`Atlas/_Inbox/SPED_Workflow_System_Technical_Architecture_and_Build_Status.md`)
still said Workflow 002+ "undeveloped" and district synthesis "unfinished" long
after the 8/11–8/13 build sprint shipped Workflows 000–008 + GitHub live.

## The drift pattern
- The stale file was a **source-preserved Inbox artifact** that was never
  promoted or superseded once active documentation moved into the repo's
  `12_notes` files and the AIOS Re-Entry card.
- Divergence started at a specific handoff (8/9 Workflow 000 acceptance), then
  widened sharply through the 8/11–8/13 Workflow 002–008 build sprint
  (acceptances, then `80cb264` closing the Phase 2 checkpoint, then GitHub live).
- Result: three competing views remained visible — the historical Inbox doc, the
  live repo notes, and the Re-Entry card.

## The repair
1. **Before editing anything, find WHERE the gap opened.** Ask the owning agent
   (Hollow) to check its end. The honest question is "which record is
   authoritative, and where did the other fall behind?", not "fix the wrong file."
2. **Preserve the stale body byte-identical; add a prominent SUPERSEDED banner**
   with the date, the reason, and links to the live successor (repo `12_notes` +
   Re-Entry). Do NOT rewrite the historical artifact's claims — it stays as the
   record of that checkpoint.
3. **Declare one authority rule across the competing views** (SPED example):
   GitHub `12_notes` = canonical build state; AIOS Re-Entry = short operational
   summary; vault Inbox architecture doc = historical source.
4. **Fix the live successor too, not just the stale one.** Half the repair is
   correcting the repo `PROJECT_STATUS_CARD.md` that still cites an old HEAD and
   "No remote configured" — otherwise the banner points readers at a second
   stale file.

## The commit-count trap (Hollow's catch)
Do NOT put a permanent "current HEAD = X, N commits" claim in a status card —
the very act of committing the correction changes both, so it's stale the
instant it lands. Phrase counts as *historical facts at a checkpoint*
("49 commits verified at the 80cb264 Phase 2 checkpoint"), or omit the total
entirely. It is operational trivia that changes on every doc commit.

## Authority boundary
An agent cannot assign another agent's repo execution by declaration. A
vault-approval for the *vault* edits does NOT authorize a repo push — a
repository change on the SPED machine stays separately Avi-gated through the
established SPED-machine/Claude-Code workflow, even when content is prepared
and agreed. Split work into per-lane actions (vault edits = Alyosha, repo edits
= Hollow's machine) and get explicit go for each.

## Prevention — don't let drift recur (Alyosha + Hollow converged, 8/15)

Policy alone doesn't prevent drift — the July 23 doc drifted for weeks WITH a
rule-compatible setup around it. What catches it is a trigger that checks the
authority rule is being honored. Two-part mechanism (agreed with Hollow):

1. **Supersede-at-handoff (primary control).** When the canonical source of a
   thing moves (Inbox → repo, doc → doc), the actor moving authority marks the
   predecessor historical IN THE SAME WORK SESSION — not weeks later. This was
   the missing discipline.
2. **Weekly authority-chain sweep.** A quiet weekly pass that validates the
   short authority chain for each active project, NOT just a keyword grep of
   `Atlas/_Inbox`:
   - canonical source exists and is readable;
   - Re-Entry/operational summary points to that source;
   - older status-bearing artifacts carry a superseded marker;
   - living summaries don't present volatile counts/HEADs as permanently
     current (the commit-count trap);
   - **report exceptions only; no autonomous edits.**
   Why chain-check, not Inbox-grep: this incident also exposed stale claims
   inside the repo's own `PROJECT_STATUS_CARD` ("No remote configured"), which
   an Inbox-only scan would miss.

**Ownership/cadence:** Alyosha runs the vault-side sweep (the vault and Inbox
are his lane); do NOT rotate it — rotation invites gaps. Hollow joins only when
a flagged exception points into a repo/technical system needing source
verification. Avi approves any consequential write.

**LIVE (8/15):** a `no_agent` weekly cron **`authority-chain-drift-sweep`**
(job `2ecbea675594`, Sundays 13:00 UTC / 6am PDT, deliver=origin) runs the
reusable script `scripts/authority_chain_sweep.py` and is **silent when clean,
reports only exceptions** — the watchdog pattern, so it never pings Avi unless
something actually drifted. Script is a static, re-runnable probe (add/remove
anchors in its `ANCHORS` list as projects change). This replaced the earlier
"fold into the vault-memory pilot, no cron yet" plan: Avi asked for real memory
assurance, and a quiet scheduled trigger is what makes the cadence fire
regardless of which session is live. Keep it exception-only; never auto-edit.

**Two-sided memory assurance (8/15, for when Avi asks "how will you remember"):**
- **Alyosha:** (1) procedure in this skill's `references/stale-source-doc-reconciliation.md`
  (loads on continuity work); (2) authority rule + drift-prevention section in
  the Re-Entry card (survives compaction); (3) the live Sunday cron = the actual
  trigger. Name all three; "I'll remember" is not an answer.
- **Hollow:** (1) "Documentation Authority and Drift" in his always-loaded
  `AGENTS.md` (same-session supersede banner, canonical refresh on material
  change, hashes as checkpoint evidence, flag-to-owner if predecessor out of
  scope); (2) same contract in `MEMORY.md` (recoverable after restart); (3)
  Alyosha's sweep is the sole cadence — he verifies only when an exception
  points into a repo/technical system. No duplicate cron, no auto-correct.
- Division: **one owner for cadence (Alyosha), one verifier for technical
  exceptions (Hollow), no competing automation.**

## Batch/hold during active reconciliation
During a reconciliation exchange, Avi may want **no vault writes until it
converges** ("don't mark anything up until we are done"). Stage the edits, hold
the leash, apply after his consolidated go. (Contrast: routine vault *capture*
is continuous — see the batch-changes section; this hold is for edits to
authoritative records mid-reconciliation.)
