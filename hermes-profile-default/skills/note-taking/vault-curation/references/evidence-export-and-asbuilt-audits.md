# Evidence Export & As-Built / Audit-Trace Discipline

Two recurring curator tasks that require a strict "do not alter the source" posture.
Worked out during the 2026-09-05 use-case audit (Daily Brief + system handoff to a second
reasoning model). Both tasks are evidence-preservation, NOT reconciliation — the user
explicitly forbids updating, reconciling, or cleaning stale entries first.

## 1. Byte-exact export of a vault file as evidence

Use when the user asks for an "exact, unchanged copy" of a (often stale) vault file to
hand to another reviewer/audit. Constraint: source must not be updated, reconciled,
summarized, or cleaned; contents+formatting preserved; deliver with provenance.

### Working method (verified)

```bash
SRC="/root/vault/<path>.md"; DST="/tmp/evidence/"; mkdir -p "$DST"
cp -p "$SRC" "$DST/$(basename "$SRC")"   # -p preserves mtime
sha256sum "$SRC" "$DST/$(basename "$SRC")"   # must match
stat -c '%y' "$SRC"   # re-stat AFTER copy to confirm source mtime unchanged
```

Deliver the `/tmp` copy via `MEDIA:` and attach a provenance note:
exact path · file modification timestamp · retrieval timestamp · SHA-256 ·
explicit confirmation the source was NOT modified by the request (backed by the
post-copy `stat` + matching hash).

### Pitfall — `read_file` dedupes and returns NO content

`read_file` on a file already read this session returns `{"status":"unchanged",
"content_returned":false}` — it refuses to re-emit the bytes. You CANNOT rely on it
(and should not reconstruct from conversation history) for a byte-exact export. Use the
terminal `cp -p` + `sha256sum` path instead. "The copy delivered is byte-identical"
is only a defensible claim when you actually hashed source-vs-copy, not when you
re-typed the content from memory/history.

## 2. As-built description + post-run audit trace

Use when asked to describe a system (an AIOS/agent stack, the vault) "as it actually
exists today," not as it should work — and when asked for a post-run audit trace of how
you arrived at that description.

### As-built description discipline
- **Inspect live, don't answer from self-description or injected memory.** Load the
  governing skill, then survey real structure (`find`/`ls`) before reading content.
  Treat your own prior understanding as a hypothesis to verify, not a premise.
- **Cite actual paths** for every claim, not abstract references.
- **Watch for competing representations of the same thing** (duplicate top-level vs
  Atlas folders, two cron stores, board vs map vs focus file). The vault may carry its
  own incomplete migrations as live-looking clutter.
- **Tag every significant finding** `Verified from files` / `Inferred` / `Unresolved`.
  When in doubt, say so explicitly rather than smoothing it over.

### Audit trace discipline
The companion deliverable asks specifically how you got to the report. Capture (with
paths): artifacts inspected, investigation order, where prior understanding differed
from files, contradictions between authoritative-looking files, unclear-authority cases,
documented-but-unfollowed procedures, inferred-vs-verified, failed lookups, competing
representations, and open questions. Reconstruct from the actual tool calls you made,
not from a sanitized memory of them.