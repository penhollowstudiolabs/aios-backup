# Verifying a peer agent's review of your vault/operational write

**Lesson 2026-08-28** — a peer agent (Hollow) reviewed Alyosha's workboard refresh and
returned 5 corrections + 2 structural notes. **Verify every claim against the canonical
vault record before applying — do not accept a peer's corrections wholesale, and do not
reject them wholesale either.**

## Pattern that worked
1. For each correction, locate the authoritative source — incident file,
   production-scope checkpoint, catalog map, build record — and confirm the claim
   against it.
2. Separate claims into three buckets:
   - **Confirmed** (verifiable in vault/live): apply them. E.g. Hollow's Amazon claim —
     ASIN `B0HDH7KF38` verified in the SP-API catalog map as a live Baby Leg Warmers
     listing.
   - **Contradicted by the vault**: correct the peer, don't propagate the error. E.g.
     Hollow said "24 rogue accounts remain uncontained," but `INCIDENT-2026-08-25.md`
     states they were ALREADY removed and the store contained — the real open item is
     the 5 queued hardening tasks. Go with the incident file, not the review.
   - **Uncorroborated** (plausible but no vault record): carry it explicitly labeled
     `per <agent> <date>` and flag it for a canonical record. E.g. Hollow's SPED
     "rollout paused/narrowed" claims weren't in any vault doc (production-scope doc
     said upload completed) — assert as peer-sourced, not vault-confirmed.
3. Tell the user where you took the peer's word vs. the vault, and which facts still
   need a canonical record.

## Why
A peer agent reviewing your write is high-value but not authoritative — it carries its
own read of state and can be wrong about the very record you're summarizing. The
canonical evidence file is the arbiter. Distinguishing confirmed / contradicted /
uncorroborated keeps the board honest and keeps you from either blindly accepting a
reviewer or defensively ignoring it.

## Rules to apply
- Canonical source beats the reviewer's framing when they conflict.
- Uncorroborated-but-plausible reviewer claims get a source label, not silent assertion.
- Report the confirmed/contradicted/uncorroborated split back to the user.
