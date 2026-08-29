# Obsidian Headless Sync Diagnosis (VPS2 aios)

When a file "should" be in the vault (another agent said "verified present", or it
was expected via Obsidian Sync) but is not on disk, diagnose rather than assume.

## Key conclusion (learned 2026-08-28)

**A healthy local sync daemon is NOT evidence the remote has the file.** Obsidian
Sync is pull-on-interval: if the *origin* device never uploaded, this VPS has
nothing to fetch, and triggering local sync does nothing. The bottleneck is almost
always the origin device, not this machine.

Symptoms matching this: a human/agent confirmed "both files are present" but the
vault showed none; the sync daemon was healthy and current the whole time.

## Reliable diagnostic sequence

1. **Check the daemon is alive and current:**
   `systemctl status ob-sync.service --no-pager`
   → expect `Active: active (running)` (unit `/etc/systemd/system/ob-sync.service`).

2. **Confirm it is actively polling:** `tail -40 <sync.log>` where log =
   `/root/.config/obsidian-headless/sync/<vault-id>/sync.log` (the vault-id is a
   32-hex string; the dir name is the vault UUID). Healthy = `YYYY-MM-DD HH:MM:SS.xxx Fully synced` heartbeats ~every 30s with no errors.

3. **The decisive check — the last remote pulls.** `grep -i download <sync.log> | tail`.
   This shows what the daemon has actually fetched from the remote. The newest
   `Downloading ... / Downloaded ...` pair tells you the last file that arrived.
   If the expected file never appears in this list, **it was never on the remote** —
   local sync is fine; the origin hasn't uploaded.

4. **Confirm config is bidirectional + connected:**
   `ob sync-status --path /root/vault` → expect `Sync mode: bidirectional`,
   `Device name: aios (Linux)`, and a host like `sync-50.obsidian.md`.
   `ob sync-list-remote` → the vault UUID must match.

## Finding the vault-id

`ob sync-list-local` prints the vault UUID + host. `ab sync-status` prints the vault
name (e.g. "Captain Avi Vault (f0286b9e…)").

## What does NOT help

- Re-running `ob sync` locally — pulls 30s on its own already; nothing new to fetch
  until the remote changes.
- Telling the user "sync is down here" — the local daemon is likely fine. Redirect
  to the origin device's upload (or a direct push like Taildrop) instead.

## Resolution

Once the origin actually uploads, the file lands here on its own within ~30s. Verify
by re-checking `grep -i download <sync.log> | tail` for the new filename, then proceed.