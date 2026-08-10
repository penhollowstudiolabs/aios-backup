# Command center pattern — one source of truth that survives memory limits

When an effort's decisions must persist regardless of agent-memory state (memory
fills up, sessions compact, another agent needs the same picture), stop keeping
"what's next" in agent memory and put it in a single canonical vault file.
First used for the SPED Workflow System (8/06): `Efforts/SPED-Workflow/SPED-Command-Center.md`.

## When to use
- Agent memory is at/near cap, so you cannot add durable facts without trimming.
- Decisions about priorities/next actions keep getting re-explained across sessions.
- More than one agent (Alyosha, Hollow, future) needs the same current-state picture.
- A target date exists (e.g. "by Aug 12") and the file becomes the live instrument
  the team reads daily instead of agent-memory.

## The file (compact, self-contained, reversible)
Create with frontmatter `type: command-center`, `owner`, `scope`, `target-date`,
and honor the domain `privacy-line` (e.g. FERPA: no raw PII — but do NOT freight
it with repeated preambles; state it once in the file per Avi's operating model).

Body sections that proved useful:
1. **Working target** — checkboxes for the stated goal(s) and date.
2. **Current priorities (by weight)** — what actually matters, ordered.
3. **Next actions / owners table** — item | owner | status | next step.
4. **Named risks / dependencies** — anything that stalls the timeline (e.g. a
   teammate's availability), stated as a risk, not hidden.
5. **Scope / lane boundaries** — what is deliberately out of scope for THIS file
   (e.g. a separate business lane stays separate) + what is deferred-intentionally.
6. **Companion pointer** — link the current-state/reconciliation map so the
   command center and the map don't drift.

## Rules that make it durable
- ANY agent reads THIS file for "what's next", never agent-memory. State that
  explicitly in the file so future sessions know it's the authority.
- Mark genuinely gated items as gated. If an item can ONLY be resolved by
  someone else's evidence (e.g. Hollow on the SPED machine), flag "gated on X;
  NOT fabricatable by Alyosha" — do not let the command center claim progress
  the team hasn't made.
- Keep it a living instrument: update at checkpoints, not just once.
- New file, additive, reversible — safe to create without heavy side-effect
  ceremony, but confirm shape/location with Avi where he's the authority.

## Companion: verify-vault-then-release memory cleanup
When freeing memory headroom (Avi at or near cap):
1. **Verify the vault actually holds the source before releasing the memory copy.**
   `search_files` the vault for the topic; read the relevant capture(s) to confirm
   they cover the detail in memory. Only then is the memory line redundant.
2. Release redundant detail, keeping durable pointers + preferences. E.g. replace
   IPs/SSH/rsync detail (now in `Tailnet State - Capture.md`) with a pointer to that
   file; keep the Ideaverse-store name and the "Syncthing retired, don't reintroduce"
   rule.
3. Show Avi old→new before applying (he owns side-effect/change actions). Apply
   as ONE `memory` batch (replace + trim) so the final char state fits.
4. Confirm the vault path in the release line matches a real, read capture.
