# Vault sync verification — exact procedure

Goal: answer "has this file synced yet?" with real evidence, not assumption.
The vault on VPS2 (`/root/vault`) is a bidirectional Obsidian write-peer on
`ob-sync.service` (`ob sync --continuous --path /root/vault`), which syncs up
to the Obsidian remote ("Captain Avi Vault"); laptop and iPhone pick updates up
on their own sync cycle.

## Steps

1. Confirm the file exists and is fresh (written recently):
   ```
   find /root/vault -type f -mmin -60   # filter to <60 min old; include a name filter if wanted
   stat -c '%y  %n' '<abs path>'        # exact mtime of the file in question
   ```

2. Confirm the sync service is the current authority and is running:
   ```
   systemctl status ob-sync --no-pager
   ```
   Look for `Active: active (running)` and the command line
   `ob sync --continuous --path /root/vault`.

3. Confirm propagation by comparing timestamps:
   ```
   journalctl -u ob-sync --no-pager -n 20
   ```
   The log prints `Fully synced` every ~30s. If the LATEST `Fully synced`
   timestamp is AFTER the file's mtime, the write has already been pushed up to
   the Obsidian remote — it is synced, and will reach the laptop (Hollow) /
   iPhone on their next sync.

## Interpretation
- `Fully synced` = local `/root/vault` == remote (Obsidian). It's the available
  evidence that an upstream write has propagated.
- A file older than the latest `Fully synced` line has been captured by
  continuous sync. No need to force/trigger anything.
- Sync is continuous, so there is no waiting period — a write made minutes ago
  is already reflected.

## Notes / gotchas
- Do not assume sync from process presence alone — check the log timestamps
  against the file mtime.
- VPS1→VPS2 rsync mirror (`/var/log/vault-sync.log`, every 30 min) is a
  separate, RETIRED path from the historical setup; Obsidian headless sync
  (`ob-sync.service`) is the current single sync authority. Do not reintroduce
  rsync as a sync method.
