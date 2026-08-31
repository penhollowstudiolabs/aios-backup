---
name: vault-retrieval-index
description: "Build a local semantic retrieval index over a vault."
version: 1.0.0
author: Alyosha
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [vault, retrieval, rag, sqlite-vec, fts5, ollama, embeddings, sovereignty]
---

# Vault Retrieval Index

Build a standalone, sovereign semantic retrieval index over a markdown vault so the agent can recall *where* something lives even when the query wording differs from the note text. Designed for the "things I captured/said never resurface" problem: an exact-word FTS search fails on paraphrase, and a hosted semantic API leaks content off-host. The answer is a local vector index with an explicit low-confidence behavior and a keyword fallback.

## When to use
- You need "given this idea, which vault note covers it?" retrieval over a large corpus.
- Sovereignty/zero-egress matters (personal/private vault content).
- The corpus is on the same host as a local embedding model (e.g. Ollama).

## Architecture
```
indexer + search CLI (python3, stdlib + sqlite-vec)
  ├─ vector table (vec0, float[N])  -> semantic recall
  ├─ meta table (rowid, path, chunk)-> content + exact source path
  ├─ FTS5 table                      -> keyword fallback on hard miss
  └─ embedding -> local Ollama endpoint (http://localhost:11434, $0)
```

## Core workflow
1. **Resolve the embedding model.** Prefer a model already resident on the host (e.g. `nomic-embed-text`) over pulling a new one — same local/sovereign/$0 profile, no duplicate download. Discover dims by embedding one probe first, then assert every chunk matches that dim.
2. **Discover vec0 dims at runtime** (embed a "probe", use `len()`), then `CREATE VIRTUAL TABLE vec_notes USING vec0(embedding float[N])`.
3. **Use the correct sqlite-vec schema:** a `float[N]` vector table JOINed to a metadata table on `rowid`, NOT a text vector column. Insert vector into vec0, capture `lastrowid`, insert (rowid, path, chunk) into meta.
4. **Load the extension by explicit path**, not by bare name — see Pitfalls.
5. **Low-confidence behavior is mandatory:** calibrate an L2-distance threshold from real data (genuine matches vs. keyword-coincidence false positives), and when the top hit exceeds it, return "No confident result" — do NOT dump keyword matches.
6. **FTS5 fallback only on a HARD vector miss** (no rows), never on a weak vector match — see Pitfalls.
7. **Acceptance suite is non-negotiable:** meaning-recall with exact source path in top-2, a negative control that must return "No confident result", zero-vault-write verification (mtime-hash), no-egress verification (CLI targets localhost only), and FTS5-populated check.
8. **Run the rebuild in the background** — sequential HTTP embedding of thousands of chunks is slow (order ~100 min for ~4k chunks on a 4-core CPU). Poll the DB file growing; do not block.
9. **Boundaries for a personal vault:** read-only on the source, hard exclusions (Personal-Finances / Legal-and-Compliance / People / `sensitivity: high` / financial-figure notes), CLI-only no HTTP listener, synthetic probes never real private notes, single `rm -rf` rollback that never touches the vault.

## Layout
- `references/pitfalls.md` — the concrete sqlite-vec / Ollama / threshold failures and fixes that bit during the first build. Read before starting.

## Delivery
Write a build record in the operator's lane (`Efforts/.../<date> - <name> - Build Record.md`) with: exact paths, acceptance result + exit code, before/during/after resource measurements, and any deviations from the brief. Keep it a *pilot* until the owner reviews — do not call it a deployed service.
