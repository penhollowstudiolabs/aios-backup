#!/usr/bin/env bash
# Daily aios backup: sync Hermes profile (secrets excluded) -> git repo -> push to GitHub
# Silent on success; non-zero exit + stderr on failure (cron alerts on that).
set -euo pipefail

SRC=/root/.hermes/profiles/alyosha
DEST=/root/backup-aios/hermes-profile
REPO=/root/backup-aios
LOG=/root/backup-aios/.backup.log

exec 2>"$LOG"

# 1. Sync live profile, excluding secrets and junk (mirror of initial rsync)
rsync -a \
  --delete \
  --exclude '.env' \
  --exclude 'auth.json' \
  --exclude 'auth.lock' \
  --exclude 'google_*' \
  --exclude 'channel_directory.json' \
  --exclude 'gateway_state.json' \
  --exclude 'gateway.pid' \
  --exclude 'gateway.lock' \
  --exclude 'gateway-starts.log' \
  --exclude 'state.db' \
  --exclude 'state.db-wal' \
  --exclude 'state.db-shm' \
  --exclude 'logs' \
  --exclude 'cache' \
  --exclude 'audio_cache' \
  --exclude 'image_cache' \
  --exclude 'images' \
  --exclude 'bin' \
  --exclude 'desktop-attachments' \
  --exclude 'desktop-ssh' \
  --exclude 'desktop' \
  --exclude 'pending_messages' \
  --exclude 'pairing' \
  --exclude 'models_dev_cache.json' \
  --exclude 'ollama_cloud_models_cache.json' \
  --exclude 'provider_models_cache.json' \
  --exclude 'web-ui-build-stamp.json' \
  --exclude 'processes.json' \
  --exclude '*.lock' \
  --exclude '*.pid' \
  "$SRC/" "$DEST/"

# Drop SQLite sidecars that rsync may carry
rm -f "$DEST"/kanban.db-shm "$DEST"/kanban.db-wal "$DEST"/state.db-shm "$DEST"/state.db-wal

cd "$REPO"

# 2. Commit if anything changed; skip silently if nothing to do
if git status --porcelain | grep -q .; then
  git add -A
  git commit -q -m "Aios backup $(date -u +%Y-%m-%d_%H%M%S)" || true
  # 3. Push (SSH key auth, no prompts)
  timeout 60 git push -q origin main
  echo "backup pushed: $(date -u +%Y-%m-%d_%H%M%S)"
else
  # nothing changed — stay silent (cron treats empty stdout as no news)
  :
fi
