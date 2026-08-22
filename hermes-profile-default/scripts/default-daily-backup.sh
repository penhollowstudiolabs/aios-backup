#!/usr/bin/env bash
# Canonical-default daily backup: sync the default Hermes home, excluding
# credentials and runtime state, into its own path in the existing repository.
set -euo pipefail

source_root=/root/.hermes
destination=/root/backup-aios/hermes-profile-default
repository=/root/backup-aios
log_file=/root/backup-aios/.git/backup-default.log
lock_file=/root/backup-aios/.git/backup-default.lock

exec 9>"${lock_file}"
if ! flock -n 9; then
  echo 'default backup skipped: repository lock is busy' >&2
  exit 75
fi

exec 2>"${log_file}"
install -d -- "${destination}"

rsync_status=0
rsync -a \
  --delete \
  --exclude 'profiles' \
  --exclude 'shared' \
  --exclude 'backups' \
  --exclude '.env' \
  --exclude 'auth.json' \
  --exclude 'auth.lock' \
  --exclude 'google_*' \
  --exclude 'channel_directory.json' \
  --exclude 'gateway_state.json' \
  --exclude 'gateway.pid' \
  --exclude 'gateway.lock' \
  --exclude 'gateway-starts.log' \
  --exclude 'pending_messages' \
  --exclude 'pairing' \
  --exclude 'logs' \
  --exclude 'cache' \
  --exclude 'audio_cache' \
  --exclude 'image_cache' \
  --exclude 'images' \
  --exclude 'bin' \
  --exclude 'desktop' \
  --exclude 'desktop-attachments' \
  --exclude 'desktop-ssh' \
  --exclude 'sandboxes' \
  --exclude 'sessions' \
  --exclude 'lsp' \
  --exclude 'cron/output' \
  --exclude '*.lock' \
  --exclude '*.pid' \
  --exclude '*.db-shm' \
  --exclude '*.db-wal' \
  --exclude 'state.db' \
  --exclude 'kanban.db' \
  --exclude 'projects.db' \
  --exclude 'response_store.db' \
  --exclude 'verification_evidence.db' \
  --exclude 'models_dev_cache.json' \
  --exclude 'ollama_cloud_models_cache.json' \
  --exclude 'provider_models_cache.json' \
  --exclude 'web-ui-build-stamp.json' \
  "${source_root}/" "${destination}/" || rsync_status=$?

if [[ ${rsync_status} -ne 0 && ${rsync_status} -ne 24 ]]; then
  echo "default backup rsync failed with exit ${rsync_status}" >&2
  exit "${rsync_status}"
fi

cd "${repository}"
git add -A -- hermes-profile-default

if ! git diff --cached --quiet -- hermes-profile-default; then
  git commit -q --only \
    -m "Default profile backup $(date -u +%Y-%m-%d_%H%M%S)" \
    -- hermes-profile-default
  timeout 60 git push -q origin main
  echo "default backup pushed: $(date -u +%Y-%m-%d_%H%M%S)"
fi
