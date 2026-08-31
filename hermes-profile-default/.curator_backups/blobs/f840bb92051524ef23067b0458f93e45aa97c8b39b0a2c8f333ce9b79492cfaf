# Recording-end aliases: closing the vocabulary gap (2026-08-30)

Field-tested finding from the Track A pilot: semantic retrieval reduces but does NOT
eliminate the vocabulary gap. A paraphrase sharing no terms with the note will still
miss, and the correct behavior is an explicit "No confident result" — not a guess.

## The field test
- Query "family business plan agenda" → `No confident result`
- Same file found instantly via "Household Wealth Operating System" (its real title)
- Conclusion: the index was right to refuse; the gap was on the capture side.

## The durable fix lives on the RECORDING end, not the retrieval end
1. **Per-note frontmatter tags/aliases** at capture time — list the alternate names,
   project labels, and "you might think of this as X" terms. Example for the HWOS file:
   ```yaml
   tags: [hwos, household-wealth, family-finances, wealth-plan, co-dreamer]
   ```
2. **A central alias map note** (small controlled vocabulary, e.g. under AIOS) mapping
   what Avi/agents actually say to the canonical note name:
   ```
   "family business plan agenda"  ->  Household Wealth Operating System / 90-Day Plan
   ```
   This is the highest-leverage piece: it captures the bridge once in one place instead
   of requiring every note to be individually perfect.

## Capture habit (build into Inbox triage / device-drop intake)
Before finalizing a note, ask "what are the other ways we might call this?" and record
them as frontmatter tags + an entry in the alias map. This permanently fixes the
failure at the source and costs less than trying to make retrieval guess every wording.

## Presentation
Bring this to the owner as a design conversation (recording workflow change), not an
immediate build. It is a process improvement to vault capture, separate from the
retrieval index itself.
