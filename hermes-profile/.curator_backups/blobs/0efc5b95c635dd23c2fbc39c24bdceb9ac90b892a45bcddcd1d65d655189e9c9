# Giving a scoped agent access to ONE Google Drive folder (8/15)

## The core truth: Google has no per-folder OAuth scope

When Avi wants a scoped agent (e.g. Mayumi) to read/write a SINGLE Drive folder
(not the whole account), the boundary is NOT an OAuth scope. Google OAuth scopes
are all-or-nothing-ish. The per-directory boundary is **Drive folder sharing +
the `drive.file` scope**, used together:

- **The agent's token uses the `drive.file` scope** — access only to files
  *shared with that account* or *that the agent creates*. Your whole Drive stays
  invisible. NOT full `drive` scope (touches everything) and NOT `drive.readonly`
  (read-only, and not folder-bound either).
- **You share the specific folder** with her Google account at **Editor**
  permission (read + write). Subfolders of a shared parent are included
  automatically.
- Result: read/write inside that folder only; everything else is invisible to her.

## Setup order

1. Create the agent's Google account (Avi-gated account creation — not ours).
2. Share the specific folder with that account at **Editor**.
3. Wire the agent's token with the `drive.file` scope + OAuth consent (the
   consent click is Avi's or the agent's, never autonomous).
4. Verify: list the folder, read a file, write a test file, confirm write-back.

## The lighter alternative — Alyosha as a Drive bridge

**Alyosha's OWN token often already holds full `drive` scope on Avi's personal
`avipenhollow@gmail.com`.** Check `google_token.json` `scopes` for the
`https://www.googleapis.com/auth/drive` scope; refresh it and confirm the bound
identity via `GET /drive/v3/about?fields=user`. When that scope is present, I can
reach ANY folder in Avi's personal Drive directly, including a folder named
"Mayumi" holding Palmstreet analytics (verified 8/15).

That means I can act as a **Drive bridge** for a scoped agent with NO second
account and NO extra consent: I read/write the folder for her, and she works via
the AgentMail lane + vault. This is dramatically simpler than provisioning a
fresh Google account + `drive.file` token, and delivers the same data.

**So when Avi asks "can I give X access to one folder?", check BOTH paths and
offer the bridge first** before assuming a new account/token is needed. Only if
Avi explicitly wants the agent to work in Drive independently (not through me)
does the account + `drive.file` + folder-share setup become the right choice.

## Pitfall — a token on file may be dead

Presence of `google_token.json` does NOT mean live access. Mayumi had a stale
token (expiry Aug 2, scopes `drive.readonly` + `gmail.send` + `calendar.readonly`)
but a live refresh returned `invalid_grant: expired or revoked` — dead. Always
prove access with a live call (refresh → `drive/v3/about` or list a folder), never
by the file's existence or scopes alone. See `google-workspace-access-check.md`
for the full verify discipline.
