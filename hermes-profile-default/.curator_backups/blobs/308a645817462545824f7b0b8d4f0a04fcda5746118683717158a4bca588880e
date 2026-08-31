# Batch embedding: the fix for a slow/fragile index rebuild (2026-08-30)

Field-tested on the Track A rebuild. Read this before any large vault-index rebuild —
it is the difference between a 96-minute fragile job and a minutes-long reliable one.

## The problem with sequential `/api/embeddings`
- One `POST http://localhost:11434/api/embeddings` per chunk. A ~4,000-chunk corpus
  on a 4-core CPU = ~96 min wall.
- It is not merely slow, it is **fragile**: a long `terminal(background=true)` runner
  can be SIGTERM'd (exit 143) by the harness mid-build, leaving a partial `index.db`
  and NO manifest. Relaunching the same slow sequential build just gets killed again.

## The fix: Ollama `/api/embed` accepts an array
`/api/embed` takes `{"model": ..., "input": [..texts..]}` and returns a list of
`embeddings` in ONE HTTP call. Embed all chunks of one note in a single request
(the note's chunks are already in memory), collapsing ~4,000 round-trips to ~450.

```python
def embed_batch(texts: list) -> list:
    req = urllib.request.Request(f"{OLLAMA}/api/embed",
        data=json.dumps({"model": MODEL, "input": texts}).encode(),
        headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=300) as r:
        return json.load(r)["embeddings"]
```

Then in the index loop, instead of `for chunk in chunks: embed(chunk)`, do
`vecs = embed_batch(chunks)` and iterate `zip(chunks, vecs)`. Same schema inserts,
same code otherwise. Build drops from ~96 min to minutes.

## Verify before a full run
- Probe `embed_batch(["a", "b"])` → expect N vectors, each `len == dims` (e.g. 768).
- Watch for exit 143 (SIGTERM, partial DB, no manifest) vs exit 0 (manifest written).
- If a background run is still needed (very large corpus), poll `index.db` size growth
  for progress; do NOT assume the process survives — batch first.

## Key distinction vs. the old guidance
The earlier skill guidance said "run the rebuild in the background" (sequential).
That worked only because it was a one-time 96-min wait. Batch embedding is the
real answer: it removes the slowness AND the fragility in one change.
