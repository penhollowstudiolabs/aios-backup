# Memory Store Hygiene (near-cap consolidation)

Reusable procedure for when the persistent memory store approaches its char cap
(e.g. >90%, so any new durable fact requires evicting an old one). Observed working
pattern on a 99% → 91% pass (2,195 → 2,011 chars).

## Avi's preference (learned, non-negotiable)
- **Propose trims, get approval, then apply.** He explicitly chose "review my
  proposed trims, then I apply what you approve" over autonomous eviction. Present
  concrete merges/trims with approximate char savings; do not silently evict facts.
- Present grouped-by-value so he can judge: core identity/roles, operating rules,
  environment facts — keep those; candidates for consolidation live among overlaps.

## Technique
1. **Group entries by value** — core identity/roles, operating rules, env facts.
   Keep the high-value sets; the trimming targets are overlapping/dated entries.
2. **Merge multi-entry blocks into one.** Two or more entries covering the same
   domain (e.g. two agent-mapping entries, two routing/OpenRouter entries) fold
   into a single consolidated entry.
3. **Fold in implied facts** (e.g. a standalone "single-human: only Avi on VPSes"
   line that is already implied by the agent-mapping entry).
4. **Trim stale dated specifics** — version/date/key noise (model versions, key
   dates) that are clock-noise, not durable facts. Keep the durable fact, drop the
   timestamp.
5. **Apply ALL changes as ONE atomic `memory` batch** (remove + add operations
   together). The char budget is checked only on the final result, so a batch can
   free room even when an individual add alone would overflow. One call, done.
6. **Report the delta** — before→after char usage and % (e.g. 99%→91%), entry
   count, and a one-line summary of each merge/trim so nothing was silently lost.

## What NOT to do
- Do not evict or rewrite entries without Avi's approval.
- Do not treat every fact as sacred; overlaps and stale dates are the free space.
- Memory captures "who the user is / current state"; procedures belong in skills.
