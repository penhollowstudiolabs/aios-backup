# Hunting an Ambiguous Referenced Item (vault)

Use when Avi references an item by description — "Hollow entered something about
agentic programming," "that operating principle I want to adopt" — without an exact
phrase, filename, or date. Lesson from a real pass that drew a hard user "Stop."

## The mistake
On a vague target, a deep-read of a 34KB vault file was opened wholesale hoping it
was the item. It was an 8/01 synthesis whose "operating principle" line was about
laptop capacity for local LLMs — not the target. Cost Avi's patience; he said "Stop."

## Correct approach: cheap discovery, then confirm, then read
1. **Recent-file listing first.** `ls -lat` (or `search_files(target:"files")`
   newest-first) on the likely home (e.g. `Atlas/_Inbox/`) to see what was actually
   entered recently — an agent's "recent entry" is usually a dated build/return
   report, not a principle doc.
2. **Targeted grep with context**, not whole-file reads. Grep the exact phrase Avi
   used (e.g. `agentic program`), plus likely synonyms (`operating principl`,
   `principle`), files_only first, then read only matched lines.
3. **Surface the 1–3 best candidates** with a one-line note each and let Avi pick.
   Do not read multi-KB files wholesale on a guess.
4. Read the confirmed target only after he chooses.

## Pitfall
- Do not equate "recently modified" with "what the agent entered as a principle" —
  recent files are often build/ops records. Grep content for the actual concept
  rather than trusting timestamps alone.
- If nothing matches, say so plainly and offer to search deeper or have Avi supply a
  phrase/date — do not keep opening large files hoping to stumble on it.
