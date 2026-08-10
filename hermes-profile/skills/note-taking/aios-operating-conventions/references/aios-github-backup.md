# AIOS Fire-Drill Backup — Hermes profile to private GitHub repo

Purpose: Avi wants a private GitHub repo so the Hermes profile (config, skills,
memory, cron) survives "everything I own burns in a fire." Set up 2026-08-09/10.

## Account + auth (verified)

- GitHub account: **penhollowstudiolabs** (confirmed by SSH greeting
  `Hi penhollowstudiolabs!` and by email notifications from that org).
- Auth = SSH key, NOT a token. Key already on the box at
  `/root/.ssh/id_ed25519`; add its `.pub` at https://github.com/settings/keys.
  Test: `timeout 20 ssh -o BatchMode=yes -i /root/.ssh/id_ed25519 -T git@github.com`
  → `Hi penhollowstudiolabs! You've successfully authenticated`.
- Token alternative exists but is worse: `ghp_` PAT with `repo` scope, expires,
  must be rotated. SSH key has no expiry. Prefer SSH.

## State as of 2026-08-10 (COMPLETE — push done, daily cron live)

- Local repo: `/root/backup-aios` (git init -b main), first commit `8988d3a`
  "Aios backup: Hermes profile snapshot 2026-08-10", plus a housekeeping
  commit excluding `lsp/` and `.backup.log` (see Pitfalls).
- **Remote: LIVE and verified.** `penhollowstudiolabs/aios-backup` (private).
  Verify push landed (don't assume): `git ls-remote origin main` + `git rev-parse
  origin/main` must match the local HEAD.
- **Daily cron: LIVE.** Job `aios-daily-backup`, `0 14 * * *` UTC (7am PDT),
  `no_agent=true` running `/root/.hermes/profiles/alyosha/scripts/aios-daily-backup.sh`
  (a thin wrapper that `exec`s `/root/backup-aios/backup.sh`). Silent on
  no-change (empty stdout = no spam), prints `backup pushed: <ts>` on a push,
  alerts only on failure. Script's rsync excludes mirror the list below.

### Cron gotcha (absolute paths rejected)
`cronjob` with `no_agent=true` requires `script` as a **relative** path under
`~/.hermes/scripts/` (or the active profile's `scripts/` dir) — an absolute
path like `/root/backup-aios/backup.sh` is rejected. Fix: put a 1-line wrapper
in the scripts dir that `exec`s the real script. Test the job with
`cronjob action=run` and confirm `execution_success: true` + `last_status: ok`.

### First-push recipe (still relevant for other repos / new boxes)
GitHub does NOT auto-create repos on push, and SSH cannot create repos. Avi
must click **https://github.com/new** → owner `penhollowstudiolabs`, name
`aios-backup`, **Private**, leave empty (no README/.gitignore/license) →
Create. Then:
```bash
cd /root/backup-aios
git remote add origin git@github.com:penhollowstudiolabs/aios-backup.git
git push -u origin main
```

## What gets backed up

`rsync -a` from `/root/.hermes/profiles/alyosha/` → `hermes-profile/` with these
EXCLUDES (durable file, copy verbatim):

```
.env  auth.json  auth.lock  google_*  channel_directory.json
gateway_state.json  gateway.pid  gateway.lock  gateway-starts.log
state.db  state.db-wal  state.db-shm
logs  cache  audio_cache  image_cache  images  bin
desktop-attachments  desktop-ssh  desktop  pending_messages  pairing
models_dev_cache.json  ollama_cloud_models_cache.json
provider_models_cache.json  web-ui-build-stamp.json  processes.json
*.lock  *.pid
```

Then `rm -f kanban.db-shm kanban.db-wal` (SQLite sidecars).

Kept: `config.yaml`, `SOUL.md`, `skills/`, `memories/`, `cron/`, `kanban.db`,
`projects.db`, `platforms/`, `scripts/`, `sessions/sessions.json`,
`state/`, `hooks/`. ~9.6 MB, 659 files.

**Why state.db is excluded:** it's the session/transcript store — chat content
better kept off GitHub even in a private repo. It is also 25 MB and churns on
every message, which bloats the repo.

## Secret hygiene (belt and suspenders)

1. rsync excludes are the first gate (above).
2. `.gitignore` in the repo mirrors the excludes.
3. **Before committing**, scan what's actually staged:
   ```bash
   git grep --cached -lE "sk-(ant|or|proj)-[A-Za-z0-9]{15,}|ghp_|gho_|github_pat_|BEGIN (RSA|OPENSSH|EC) PRIVATE"
   git ls-files | grep -iE "\.env|auth\.json|google_token|client_secret|\.pem$|\.key$|id_ed|id_rsa"
   ```
   Expected false positives: skill DOCUMENTATION files contain placeholder
   token examples (`sk-ant-...` in `skills/.../*.md`) — harmless, they are
   examples. Real tokens are in `.env`/`auth.json`/`google_*`, which are
   already excluded.

## Identity for commits

`git config user.name "Avi Penhollow"` / `user.email "avipenhollow@gmail.com"`.

## Pitfalls

- **SSH can't create repos.** You can only push to a repo that exists. The
  empty private repo must be created in the browser first. Don't try
  `git push` to a nonexistent repo and call it "almost done" — the repo does
  not appear.
- **rsync can drag in tooling dirs.** `hermes-profile/lsp/` (node_modules
  symlinks) slipped in on the first sync and needed a housekeeping commit
  (`git rm -r --cached hermes-profile/lsp` + add `lsp/` to excludes).
- **Log files land inside the repo dir.** `backup.sh` wrote `.backup.log` into
  `/root/backup-aios/` (the repo root), and it got committed. Add `.backup.log`
  to `.gitignore`; better, write the log outside the repo or `exec 2>` it to
  /tmp.
- **Don't put the PAT in chat or in a doc.** If Avi ever goes the token route,
  the token is pasted into config/credential store only, never into a vault
  note or Telegram (creds never in chat — Avi rule).
- **Private repos are free on GitHub's free plan** (verified 8/09/2026):
  unlimited private repos, $0 forever. GitHub charges for Actions minutes,
  LFS large files, and Team/Enterprise features — none of which a small
  config/data backup uses. No bill coming; don't let Avi worry about cost.
- The vault (`/root/vault`) is deliberately NOT in this repo: it already
  survives via ob-sync to Obsidian remote. The repo covers what has no other
  off-box copy (Hermes profile state).
