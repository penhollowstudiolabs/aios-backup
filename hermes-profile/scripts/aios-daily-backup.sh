#!/usr/bin/env bash
# Cron wrapper -> real backup script. Silent on no-change, prints on push.
exec /root/backup-aios/backup.sh
