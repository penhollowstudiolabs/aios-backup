# Verifying external-account access (Google Workspace, etc.)

Captured 8/09 after I told Avi I had **"no access"** to Google Workspace when the
token was actually live and working. The mistake was checking the wrong places
for evidence. This is a recurring class of error — "does this agent have access
to service X" — so here's the correct discipline.

## The wrong places to check (this is what failed)

For Google Workspace, I concluded "no access" because none of these turned up:
- `.env` grep for `GOOGLE|GMAIL|GDRIVE|OAUTH` — found only commented example keys
- `hermes auth list` — showed only anthropic / nous / openrouter
- `which gws` — gws CLI not installed

All three missed the real credential store. **Absence in these places proves
nothing about a service skill's own credentials.**

## The right places to check

A connected-service skill keeps its OWN credential files and its own
authoritative check. For the `google-workspace` skill:

```bash
# credentials live HERE, not in .env:
ls ~/.hermes/profiles/<profile>/google_client_secret.json \
      ~/.hermes/profiles/<profile>/google_token.json

# authoritative status (prints AUTHENTICATED if live):
python ~/.hermes/profiles/<profile>/skills/productivity/google-workspace/scripts/setup.py --check
```

Token auto-refreshes (`google_token.json` mtime updates as it's used), so a
recent mtime is a secondary signal the token is actively working.

## Prove it with a live call, don't trust the file alone

A token file existing doesn't mean it currently works. Fire a cheap read call
and confirm it returns:

```bash
GAPI="python .../skills/productivity/google-workspace/scripts/google_api.py"
$GAPI gmail search "in:anywhere" --max 1   # or: $GAPI drive search "x" --max 3
```

If it returns JSON, access is real and current.

## Which account is it bound to? (personal vs work)

A token only reaches the ONE Google account that authorized it. Confirm the
bound identity via the Gmail profile endpoint (the token's access_token):

```bash
curl -H "Authorization: Bearer <access_token>" \
  https://gmail.googleapis.com/gmail/v1/users/me/profile
# -> "emailAddress": "avipenhollow@gmail.com"
```

On 8/09 Avi's token was `avipenhollow@gmail.com` — his **personal** account.
His **work / district Drive is a separate Google Workspace account the token
cannot see.** Do not assume one OAuth token reaches all his Google storage.

Consequence for the district-docs task: Google Docs from the work Drive run the
manual path (File → Download → Markdown), and PDFs/screenshots get sent to me —
unless Avi deliberately sets up a second work-account OAuth (which carries
district-policy considerations).

## General rule

Before saying "I don't have access to X," look for the skill that manages that
service and check ITS credential files + its own `--check`/status command plus a
live read call. Runtime access is the ground truth; `.env` and `hermes auth list`
and CLI presence are not a complete inventory.