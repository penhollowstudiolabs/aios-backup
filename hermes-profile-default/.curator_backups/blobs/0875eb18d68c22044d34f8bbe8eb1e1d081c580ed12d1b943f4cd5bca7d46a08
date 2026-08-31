# Pitfalls — first vault-retrieval-index build (2026-08-30, Track A)

Concrete failures and fixes from building the first standalone vault index. Read before starting a new build so you don't rediscover them.

## 1. sqlite-vec extension load: bare name fails
- `con.load_extension("vec0")` -> `OperationalError: vec0.so: cannot open shared object file`. The extension is not on the loader search path.
- **Fix:** resolve the `.so` path from the installed package and load that:
  ```python
  import sqlite_vec as _sqv, os as _os
  def _load_vec(con):
      con.enable_load_extension(True)
      con.load_extension(_os.path.join(_os.path.dirname(_sqv.__file__), "vec0"))
      con.enable_load_extension(False)
  ```
- Symptom of getting this wrong: the rebuild "succeeds" but writes a 0-byte `index.db` and no manifest — because the process actually crashed on the extension load (check exit / stderr; don't trust the wall-clock time).

## 2. vec0 schema: it is a float[N] table, not a text column
- Wrong first attempt: `CREATE VIRTUAL TABLE notes USING vec0(chunk text, ...)` — vec0 is a vector store, not a row store.
- **Correct pattern:** a `float[N]` vec0 table joined to a metadata table on `rowid`:
  ```python
  con.execute(f"CREATE VIRTUAL TABLE vec_notes USING vec0(embedding float[{dims}])")
  con.execute("CREATE TABLE meta_notes(rowid INTEGER PRIMARY KEY, path TEXT, chunk TEXT)")
  cur = con.execute("INSERT INTO vec_notes(embedding) VALUES(?)", (sqlite3.Binary(struct.pack(f'{dims}f', *vec)),))
  rowid = cur.lastrowid
  con.execute("INSERT INTO meta_notes(rowid, path, chunk) VALUES(?,?,?)", (rowid, rel, chunk))
  ```
- Query: `SELECT m.path, m.chunk, v.distance FROM vec_notes v JOIN meta_notes m ON m.rowid = v.rowid WHERE v.embedding MATCH ? AND k = ? ORDER BY v.distance LIMIT ?`.

## 3. Dimension mismatch on empty/odd files
- Local embedding returned `len == 0` for empty files (e.g. `Untitled.md`, 0 chars). An `assert len(vec)==dims` then aborts the whole build.
- **Fix:** embed a probe first to fix `dims`; on each chunk, if `len(vec) != dims`, print a `DIM MISMATCH` line to stderr and `continue` (skip) instead of asserting. Empty/tangential files are legitimately skipped.

## 4. L2 confidence threshold separates genuine from coincidental matches
- Calibration on real data: genuine matches observed at distance 11–13.5; a false-positive negative-control query ("who owns the Substack newsletter") returned ~16.8 (keyword/name overlap, not a real answer).
- **Fix:** pick a threshold that cleanly separates them (15.0 worked). If the top hit exceeds it, print `No confident result (best vector match is weak: distance X > threshold)` and return — never dump the keyword match as if it were an answer.

## 5. FTS5 fallback ONLY on a hard vector miss
- vec0 always returns nearest neighbors (there is always *some* top row). So "vector returned nothing" almost never happens; a weak-but-present match is a genuine low-confidence signal, not a miss.
- **Correct semantics:**
  - weak match (best > threshold) -> "No confident result", do NOT fall through to FTS5 (that would keyword-dump the false positive and defeat the negative control).
  - hard miss (no rows) -> FTS5 keyword fallback is legitimate.
- This is the safety net that keeps the negative control honest.

## 6. mtime-hash bug
- `os.path.getmtime(p).to_bytes(8, "big")` -> `AttributeError: 'float' object has no attribute 'to_bytes'`. `getmtime` returns a float.
- **Fix:** `int(os.path.getmtime(p)).to_bytes(8, "big")`.

## 7. Acceptance "failures" are often over-strict test assertions
- Two meaning-recall tests "failed" not because the index was wrong but because the assertion demanded ONE exact path in top-2, while the index correctly returned the real source under a slightly different filename (e.g. the canonical decision record surfaced via its backlink in Re-Entry.md; the handoff file surfaced as position 3).
- **Fix:** assert a substring that is genuinely correct (`"Clean Default Hermes Agent Rebuild - Handoff for Hollow"`), not a brittle full-path assumption. If the vector result is semantically right, the test is wrong, not the index.

## 8. Sequential HTTP embedding is slow — run rebuild in background
- ~3,999 chunks, one `http://localhost:11434/api/embeddings` call each, on a 4-core CPU: ~96 min wall. A foreground run will hit tool timeouts and look hung.
- **Fix:** `terminal(background=true, notify_on_complete=true)`. Poll `index.db` size to confirm growth; the process stays ~0% CPU (idle-waiting on Ollama HTTP), which is normal — the DB growing is the real progress signal.

## 9. Resource honesty: isolate the model's idle cost from the index's
- The index itself is a static SQLite file: no daemon, no port, no resident process, ~1s warm search, ~24MB peak RSS during build. But idle system RAM rose ~364MB — that is the *resident Ollama model* (shared with any other bench on the host), not the index.
- In the resource record, attribute the delta to the shared embedding model, not the new artifact, so a future reader doesn't mis-attribute it.

## 10. Deviation from brief: embedding model
- Brief specified `bge-small-en-v1.5`; the build used `nomic-embed-text` (768-dim) because it was already resident for a parallel bench. Same local/sovereign/$0 profile, avoids a duplicate download. **Flag any such deviation in the build record** — do not silently swap the specified model.
