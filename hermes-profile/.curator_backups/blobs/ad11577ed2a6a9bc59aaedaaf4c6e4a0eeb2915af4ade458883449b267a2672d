# Re-authorizing Alyosha's revoked Google OAuth token (8/14)

## When to use
Alyosha's Google Workspace access died (`invalid_grant: Token has been expired or revoked` on `setup.py --check`). This is the proven re-auth flow. It is **separate from checking access** — see `google-workspace-access-check.md` for the verify-live step; this file is the *re-consent* flow.

## Trigger signature
`setup.py --check` → `TOKEN_REVOKED: invalid_grant: Token has been expired or revoked.`
A dead token means Google access is silently broken — calendar reads, gmail search, drive checks all fail. Avi is the only one who can consent (it's his personal account).

## The flow (proven working)
1. **Generate the consent URL** (correct flags for THIS setup.py version — it does NOT accept `--services`/`--format json`):
   ```bash
   GSETUP="python ${HERMES_HOME:-$HOME/.hermes}/skills/productivity/google-workspace/scripts/setup.py"
   $GSETUP --auth-url
   ```
   Copy the full URL out of stdout.

2. **Send Avi the URL.** He opens it in a browser signed into the personal account (`avipenhollow@gmail.com`). Consent screen: "Alyosha Google Access wants access…" → Continue/Allow.

3. **After Allow, the redirect fails on `localhost:1` — that is EXPECTED.** The code lives in the address-bar URL. Have Avi copy the ENTIRE address-bar URL (contains `code=...`) and paste it back. This is the only thing you need.

4. **Exchange the code** (no `--format json` flag on this version):
   ```bash
   $GSETUP --auth-code "<full localhost:1/?code=... URL>"
   ```
   → `OK: Authenticated. Token saved to …/google_token.json`

5. **Verify LIVE** — not just saved. Do a real API call (e.g. Drive `about?fields=user,storageQuota`), or `setup.py --check` should now say authenticated.

## Pitfalls (all hit 8/14)
- **Mobile browsers freeze on the `localhost:1` redirect** (`ERR_UNSAFE_PORT` or a dead-looking page that never yields the code). The consent page can also stall and leave you staring at the `consentsummary` URL with no `code=`. **A desktop browser on the laptop is the reliable path.** Say this UP FRONT — do not first say "mobile is ideal" and then flip to "laptop is better" after the user hits the freeze (Avi caught exactly this contradiction and it reads as not thinking the flow through).
- **The consent URL is session-tied.** If it stalls and produces no code, regenerate a fresh one (`--auth-url` again) rather than fighting the frozen session. Don't make Avi chase a dead tab a third time.
- **Copy from the address bar, not the page.** On mobile especially, the code is only in the address-bar URL, not visible page content.
- **ERR_UNSAFE_PORT is fine** — `localhost:1` is deliberately an invalid port; Google uses it purely as a callback carrier for the code. The "This site can't be reached" page is the SUCCESS state; just extract the code.
- **When Avi reports a step is frozen/done, TRUST his report and don't re-instruct the step (8/14 correction).** He said the consent page was frozen after he'd already hit Continue, and I replied by re-explaining how to hit Continue — he had to stop me: *"Stop being condescending. I already hit that and it's been frozen."* The lesson: if the user says they already did X and it didn't work, treat X as done and diagnose the *stall/redirect* (or regenerate the session), never re-walk them through X as if they'd missed it. Re-instructing a step the user already reported doing reads as not listening.
- The setup.py in the profile accepts `--auth-code <URL>` and `--auth-url` but NOT `--services` / `--format json` (those flags error as "unrecognized arguments"). Don't pass them.
- **Cross-profile consent URL — set HERMES_HOME (8/15).** When generating the URL for a DIFFERENT profile than the one you're in (e.g. Mayumi's `ilocos` on VPS1), setup.py falls back to the DEFAULT profile (`/root/.hermes`) if `HERMES_HOME` is unset, printing `[HERMES_HOME fallback] ... Falling back to /root/.hermes, which is the DEFAULT profile — not 'ilocos'. Any data this process writes will land in the wrong profile.` That would write the token to the wrong home and the target integration would never see it. Fix BEFORE `--auth-url`:
  ```bash
  export HERMES_HOME=/root/.hermes/profiles/ilocos
  PY=/usr/local/lib/hermes-agent/venv/bin/python   # 'python' is NOT on the ilocos PATH
  $PY /root/.hermes/profiles/ilocos/skills/productivity/google-workspace/scripts/setup.py --auth-url
  ```
  Verify the token lands in the profile (`ls /root/.hermes/profiles/ilocos/google_token.json`), not the default home.
- **Scope decision — `drive.file` vs full `drive` (8/15).** The setup.py tool generates the FULL `drive` scope by default (whole Drive), not the folder-scoped `drive.file` an agent might want. `drive.file` = only files/folders shared with the app or it creates (cannot roam the whole Drive); full `drive` = entire Drive. Surface the blast-radius difference explicitly and let Avi choose — don't assume. On 8/15 Avi picked full `drive` because he's restructuring his Drive anyway and migrating what he doesn't want touched off it, and needed the agent autonomous that night.
- **For a PEER agent on a remote host / Docker sandbox, see `google-oauth-remote-agent-and-sandbox.md`** — the HERMES_HOME-profile-write pitfall and the host-`--check-live`-OK ≠ sandbox-usable two-layer verification gap are covered there in full. This file is for Alyosha's OWN token.

## Bonus: what a live token unlocks
With the token alive, the Drive `about` API returns real storage: on 8/14 it read `288.77 GB used / 5497.56 GB (5TB) limit` for avipenhollow@gmail.com — usable to confirm storage-migration sizing instead of relying on account-dashboard guesses.
