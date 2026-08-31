# Alias wiring pitfall — documenting well is NOT automatic (2026-08-30)

The one correction that mattered most when adopting recording-end aliases with Avi.

## The trap
Avi's first instinct: "if we document well (add aliases at capture), retrieval will
just work." That is only HALF true. A retrieval index that reads the note **body +
filename** does NOT read the `aliases:` frontmatter field — the alias is invisible to
retrieval even though it sits inside the note.

## The rule
The recording convention and the retrieval plumbing are **two halves that must both
exist**. Neither works alone:
- aliases in frontmatter but indexer not wired → aliases do nothing.
- indexer wired but notes never get aliases → nothing to read.

## The wiring fix (verified working)
Parse `aliases:` frontmatter and PREPEND it to the text before chunking/embedding, so
alias terms are embedded with the chunk:
```python
aliases = frontmatter_aliases(text)          # extract aliases list from frontmatter
text_for_index = text
if aliases:
    text_for_index = "ALIASES: " + "; ".join(aliases) + "\n\n" + text
# then chunk/embed text_for_index, not text
```
Field result: the generic query "family business plan agenda" that previously returned
"No confident result" now surfaces the HWOS note via its aliases.

## Present it correctly
When pitching the recording-end idea to the owner, say up front it needs BOTH the
capture convention AND the indexer wiring — so they don't expect the documenting
habit alone to fix retrieval. Use the `aliases:` field (Obsidian-native), not just
`tags:`, because that is the field the indexer is wired to read.

See `recording-end-aliases.md` for the full aliasing design (frontmatter aliases +
central alias map + capture habit).
