# aios-backup

Fire insurance for Avi's VPS 2 (aios) — the Hermes Agent profile, backed up daily to a private GitHub repo.

**Repo:** private, `penhollowstudiolabs` account
**Backup source:** `/root/.hermes/profiles/alyosha` on aios (VPS 2)
**Cadence:** daily, 14:00 UTC via Hermes cron job `aios-daily-backup` (silent when nothing changed, alerts on push failure)
**Last updated:** see git log

## What's in here

- `hermes-profile/` — Hermes config, SOUL.md, all skills, memories, cron jobs + outputs, kanban, projects, scripts
- `backup.sh` — the sync+commit+push script that runs daily

## What's deliberately NOT in here (secrets never go to GitHub)

| Excluded | Why |
|----------|-----|
| `.env`, `auth.json` | API keys, OAuth credential pools |
| `google_token.json`, `google_client_secret.json` | Google Workspace OAuth |
| SSH keys (`id_*`, `*.pem`) | Host credentials |
| `state.db` (session transcripts) | Chat content kept off GitHub |
| `logs/`, `cache/`, `bin/`, `lsp/` | Transient / reinstalled tooling |

**Credentials live only on the VPS** (and in Bitwarden). After a restore, re-enter API keys / OAuth before the agent is fully operational again.

## Restore after a fire (new VPS)

```bash
# 1. Install Hermes Agent (https://hermes-agent.nousresearch.com/docs)
# 2. Add the SSH deploy key / regenerate auth, then:
git clone git@github.com:penhollowstudiolabs/aios-backup.git ~/backup-aios
# 3. Copy the profile into place:
rsync -a ~/backup-aios/hermes-profile/ ~/.hermes/profiles/alyosha/
# 4. Re-enter credentials: API keys in .env, `hermes auth`, google OAuth
# 5. Restore cron: `hermes cron` should pick up jobs.json (verify)
# 6. Re-add the SSH key to GitHub if it changed
```

You should be operational with all skills, memory, and cron intact.

## How the daily backup works

`backup.sh` (invoked by cron):
1. `rsync` the live profile into `hermes-profile/`, excluding secrets/junk
2. `git add -A && git commit` if anything changed
3. `git push -q origin main` (SSH key auth, no prompts)

Failure to push → cron alerts to Telegram. Silence = nothing changed = all good.

## Manual run

```bash
/root/backup-aios/backup.sh
```
