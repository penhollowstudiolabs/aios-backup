# Parallel-session attribution & verification precision

Lesson from the 2026-08-30 AIOS Memory Architecture Council, where a plan record said
"Honcho not installed" but the live VPS already ran a full Honcho stack.

## The trap

An agent asserted "I did not stand this up" from a plan doc's "not installed / awaiting
sign-off" status, treating the running stack as an unexplained intruder. In fact it had
been stood up by the *same agent in a parallel session* minutes earlier under the owner's
step-by-step approval. A stale plan summary is not evidence of an unexpected actor.

## The correct workflow

Before attributing a material live-state change to an unexpected actor, or flagging a
contradiction as unresolved:

1. **Verify live state with timestamps**, not with plan records or memory:
   - containers: `docker ps -a --format '{{.Names}}\t{{.Status}}\t{{.CreatedAt}}'`
   - files/dirs: `stat -c '%y %n' <path>` (note compose checkout, `.env`, config mtimes)
   - listening ports: `ss -tlnp` to confirm ownership and loopback binding
2. **Check for your own other-session context.** The parallel-session counterpart (same
   profile, a sibling subagent) may have executed the work. Confirm via a sibling-write
   warning, an AgentMail/session trail, or the owner, before drawing a conclusion.
3. **If still unattributable, raise it as a question to the owner** — do not present an
   unexplained actor as a conclusion.

## Verification precision

- "X's documented file-state verification" ≠ "independent verification." If you cannot
  inspect the other node directly (different host, no access), say so and attribute the
  actor/mechanism exactly.
- Preserve stated limitations rather than upgrading them: e.g. file-state rollback proven
  (config/MEMORY hashes match pre-state, provider never set) does NOT prove absence of
  network egress when no packet trace was captured.
- Do not let measurements of one live component validate a claim about a different,
  unbuilt one (Track B's measured RAM cannot confirm Track A's "negligible idle").
  Resource claims on an unbuilt component need their own before/during/after measurements.
