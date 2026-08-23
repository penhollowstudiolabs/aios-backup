---
name: operational-state-curation
description: "Use when reconciling shared operational maps after a change."
version: 1.0.0
author: Alyosha
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [continuity, vault, operations, re-entry, evidence, multi-agent]
---

# Operational State Curation

Use when a material operational change—an accepted migration, agent cutover, ownership transfer, system rebuild, or verified infrastructure transition—must be reflected in a shared vault without rewriting the project archive.

## Purpose and authority

The decision/evidence record is canonical for acceptance evidence, exact technical state, commands, and rollback artifacts. Operational summaries exist to orient future work:

- fleet or system map;
- Re-Entry card;
- current workboard;
- relevant agent working notes.

Never turn an orientation pass into a technical migration, service audit, project rewrite, or new source of authority.

## Evidence-bound workflow

1. **Establish scope and write authority.** Confirm exactly which orientation files may change. If the user restricts work to fleet continuity, do not touch project notes, configurations, services, credentials, or rollback materials.
2. **Read the canonical accepted record and target summaries.** Use the accepted record for new facts; use target files only to identify stale statements and historical context.
3. **Separate facts by type.** Record only: the accepted identity/topology change, verified systems or peer checks named in evidence, preserved endpoint/identity if stated, and rollback retention boundary.
4. **Update the hierarchy deliberately.**
   - System/fleet map: topology and durable operating posture.
   - Re-Entry: compact current posture at the top; retain older material under a clearly historical label when useful.
   - Workboard: one bounded summary, explicitly stating that project lanes and permissions did not change unless they did.
   - Agent notes: the practical re-entry facts and any explicit no-touch boundary.
5. **Preserve prior evidence.** Do not delete prior cutover descriptions solely because they are stale. Mark them historical or superseded if their continued presence could otherwise mislead.
6. **Protect rollback state.** If a legacy profile/gateway/archive is retained, describe it as stopped/reference-only and include the retention date. Do not restart, delete, or alter it without explicit authorization.
7. **Read back each changed file.** Verify the exact summary language, dates, and authority statements. Then report: every file changed, the factual changes, and any contradictions or missing canonical record.

## Writing standard

- Lead with date, accepted status, and canonical-source boundary.
- Keep summary claims narrow and verbatim in meaning; do not infer provider, access, model, project, or service changes from a successful cutover.
- Use exact profile labels such as `default` and named legacy profiles exactly as supplied.
- Flag ambiguity instead of silently resolving it.

## Pitfalls

- **Do not mistake a successfully rebuilt default profile for broad permission to revise all operational state.** A cutover may leave project lanes, integrations, model routing, and service ownership unchanged.
- **Do not elevate a workboard or Re-Entry card above the decision/evidence record.** Say plainly which source is canonical.
- **Do not erase rollback context.** The retained legacy path is a safety boundary, not clutter.
- **Do not declare a system map fully current just because one topology item changed.** Update only the accepted scope and flag other stale sections.
- **Do not silently normalize contradictions between old summaries and fresh evidence.** Preserve or flag the contradiction.
