# Handoff vs. provenance forensics — scope boundary

**Lesson learned 2026-08-28** (Avi correction on a Patchi landing-page recovery).

## The incident
A completed deliverable (Patchi landing page, `patchi.ilocosemporium.com`) existed with **no build record** in the vault. Alyosha needed to know who built it and when. Instead of dispatching, Alyosha went deep into server forensics:
- SSH'd to the store VPS (ilocos)
- inspected nginx site configs + symlink mtimes
- read systemd unit (`patchilove.service`)
- ran `ss`/`/proc` to find the Node process on :3010
- read Lovable `project.json`, README, AGENTS.md, deploy dir

Avi corrected: *"I thought I was asking Hollow and Dewey? no need for you to do all this."*

## The correct pattern
1. **Cheaply verify the deliverable is live** (HTTP 200 / DNS / service check) only if it helps the handoff card.
2. **Dispatch provenance/attribution recovery to the owning builder** (the agent that built it) via a handoff card in `Atlas/_Inbox` + AgentMail.
3. The origin agent confirms the artifact *exists*; the **builder confirms who made it and when**. Do not infer authorship from filesystem/history/metadata archaeology.

## Why
Deep machine forensics to attribute work you did not do is:
- overreach into the builder's lane / the user's intent for a handoff,
- slow and out of scope, and
- risks fabricating provenance from ambiguous metadata (e.g. an mtime is a deploy time, not an author).

## Rules to apply
- Origin agent = verify existence, not authorship.
- Attribution = the builder's confirmation, not the origin's inference.
- If the builder cannot confirm, mark provenance UNKNOWN rather than guessing from metadata.
