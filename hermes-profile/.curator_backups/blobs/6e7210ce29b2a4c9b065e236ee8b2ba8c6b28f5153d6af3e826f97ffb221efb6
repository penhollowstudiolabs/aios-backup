# Provisioning Google OAuth for another agent (remote host) + the sandbox verification boundary

Captured 8/15 when setting up Mayumi's (VPS1/ilocos) Google Workspace access on
Avi's `avipenhollow@gmail.com`. Two distinct lessons: (1) how to provision OAuth
for a DIFFERENT profile on a REMOTE host, and (2) the critical verification gap
— host-profile validity is NOT sandbox usability when the agent runs in a Docker
sandbox.

## Lesson 1 — provision OAuth for another profile/host, correctly wired

The google-workspace `setup.py` resolves its home from `HERMES_HOME` and falls
back to the DEFAULT profile (`~/.hermes`) when unset — the wrong target for a
profile-based agent. The reauth flow in `google-oauth-reauth-flow.md` covers
Alyosha's OWN token; for a peer agent the consent is still Avi's (it's his
account), but the WRITE must land in the peer's profile.

Sequence (all over SSH to the remote host):
1. Confirm the target profile + its existing (possibly dead) token:
   `ls ~/.hermes/profiles/<profile>/google_token.json` — a token that returns
   `invalid_grant: Token has been expired or revoked` on refresh is DEAD.
2. Set `HERMES_HOME` to the PROFILE home, not the default, when generating and
   exchanging:
   ```bash
   export HERMES_HOME=/root/.hermes/profiles/ilocos
   python .../skills/productivity/google-workspace/scripts/setup.py --auth-url
   ```
   If you see `[HERMES_HOME fallback] ... Falling back to /root/.hermes` you are
   about to write into the WRONG profile. `--auth-url`/`--auth-code` for this
   setup.py version: no `--services`/`--format json` flags.
3. Consent is Avi's (desktop browser; the `localhost:1` redirect page is the
   SUCCESS state — copy the full address-bar URL with `code=`).
4. Exchange `--auth-code "<callback url>"` with `HERMES_HOME` still set → token
   saved to `~/.hermes/profiles/<profile>/google_token.json`.
5. `setup.py --check-live` → `LIVE_CHECK_OK`.

## Lesson 2 — host-profile OK is NOT sandbox usable (the one that bites)

`setup.py --check-live` returning OK on the HOST proves the host-profile token
works. It does NOT prove the agent can use it, because Hermes profiles can
execute in a **Docker sandbox** with its OWN mounted credential path.

For Mayumi: the sandbox mounts `/root/.hermes/profile-integrations/ilocos/google`
at `/integrations/google`, while the fresh token initially existed only at the
host-profile path. The mounted integration still held the REVOKED Aug 2 token,
and the sandbox's `/root/.hermes/google_token.json` was empty. So host
`LIVE_CHECK_OK` was true while the sandbox was still broken.

### The fix (Hollow-verified 8/15, no gateway restart)
1. Preserve the old revoked integration token as backup.
2. Sync the fresh token into the mounted integration path:
   `/root/.hermes/profile-integrations/ilocos/google/google_token.json`.
3. Point the persistent sandbox's `~/.hermes/google_token.json` at
   `/integrations/google/google_token.json`.

### Verify FROM the sandbox, not just the host
Real end-to-end checks from the agent's actual execution sandbox:
- setup check → AUTHENTICATED
- Drive metadata read of the real target folder
- create a temp file/doc INSIDE that folder
- write content to it
- verify the parent folder
- move the temp doc to Trash (cleanup)

## General rule
For ANY agent that executes inside a container/sandbox with a mounted credential
path, "host token is valid" and "agent can use it" are two different claims.
Provision the host token, then verify from the sandbox's OWN view of its mounted
credential file — never stop at host-profile `--check-live`.

## Scope decision (Avi-gated, 8/15)
Avi chose FULL `drive` scope (option B) over scoped `drive.file` deliberately —
he plans to restructure/migrate his Drive, so broad access is acceptable for the
data-collection agent. If scope ever needs tightening, re-auth with `drive.file`.
This is a per-setup Avi decision; surface the blast-radius tradeoff explicitly
(full = whole Drive) rather than assuming.
