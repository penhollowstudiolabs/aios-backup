# Vault domain audit — per-area verdict ledgers (SPED → Ilocos pattern)

When Avi wants an existing vault area "audited/cleared" (curation posture: fine-tune
each existing area before adding new ones), run the audit that was proven on SPED
(8/06) then Ilocos Areas 1+2 (8/10): read-only, per-file verdicts, a dated ledger
per area, NO rewrites/reorganization without Avi's choice.

## Conventions (Avi-approved)

- **Read-only everywhere.** No file moved, renamed, modified, or deleted in the pass.
- **Evidence-first:** on-disk SHAs / byte-comparisons / dated markers outrank summary
  claims; live systems (WooCommerce, Google Sheet, Amazon Seller Central, Palmstreet)
  are the authority where claims touch them.
- **Verdict taxonomy** (one per file): `verified by Avi` · `verified with exception`
  · `unclear-needs-provenance` · `requires live verification` · `source input — preserved`.
- Sources preserved unchanged. Ledger is a NEW dated file in the audited area;
  proposal card lives in `Atlas/_Inbox/`.

## Execution — parallel delegation (ilocos 8/10 recipe)

Areas with ~30–55 files are perfect for `delegate_task` parallel fan-out (2 at a
time; each leaf is read-only and cannot ask Avi):

- Give each subagent: the absolute vault path, the verdict taxonomy, the method
  (list files → read each ≥60–80 lines → classify), and "look for contradictions
  BETWEEN files and stale/superseded items — those are the gaps."
- Output contract: ONLY a markdown ledger (summary buckets + File|Verdict|Note
  table + top 3–5 real findings). Cap word count. Tell them not to write any files.
- Consolidated results return to the parent; verify the summaries yourself before
  writing the durable ledgers into the vault (subagent reports are self-reports).

## After the ledgers: verification checklist

Produce a second artifact — `YYYY-MM-DD - <Area> Verification Checklist.md` — the
mechanical pass that follows the read pass. Rows grouped by who does what:
A = Hollow/live-system checks (laptop, residential egress), B = Avi-only account
checks, C = Avi + Kathleen business decisions, D = cosmetic status fixes needing
one-word approval. Every row: the gap, how to verify, what evidence to bring back.
This is NOT a re-read — it's live checks + decisions only. Hollow "returns to the
audit tomorrow" and runs it; Alyosha reconciles findings into the ledgers.

## Pitfalls learned 8/10

- **Check for a prior audit ledger first.** Area 1 already had an 8/08 ledger; the
  new pass should REFINE it (`- Reconciliation` suffix), not duplicate or ignore it.
- **Avi may change the audit's premise mid-flight.** On 8/10 he retired the
  systematic Claude-chat intake the plan/ledger were built around. When that
  happens, mark the affected docs `superseded-by-direction-YYYY-MM-DD` with a dated
  blockquote recording his direction — preserve content, update status honestly.
- **Capture direction as you go** (see main SKILL.md): when Avi says a lot is
  happening that isn't getting captured, write the direction note to
  `Atlas/_Inbox/` immediately — don't batch it at session end.

## Sending vault links to Avi

When Avi wants to open the files under discussion, send Obsidian deep links
(they open directly in "Captain Avi Vault" on his laptop/iPhone). Format —
URL-encode the vault name and the path:

```
obsidian://open?vault=Captain%20Avi%20Vault&file=Efforts%2FIlocos-Emporium%2F2026-07-26%20-%20Safe%20Legacy%20Context%20and%20Code%20Intake%20Plan.md
```

Caveat: some Telegram clients block custom URI schemes — if the link doesn't open,
tell him to copy it into a browser/terminal and it routes to Obsidian.
