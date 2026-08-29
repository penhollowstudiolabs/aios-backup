# Obsidian Sync — origin-side root cause (Windows laptop)

Companion to `references/obsidian-headless-sync.md`. That file diagnoses a missing
vault file from the VPS2 side ("the origin never uploaded"). This one explains the
most common *why*, learned 2026-08-29 via Hollow's correction.

## Two mount points, one logical vault

- Windows laptop: `C:\Users\Owner\Documents\Captain Avi Vault`
- Linux VPS (VPS2): `/root/vault`

Both use identical relative paths (`Atlas/_Inbox/<file>`, `AIOS/...`, etc.). Finding
the right *folder* structure on VPS2 but a missing *file* is normal and expected —
it does not by itself mean anything is wrong with the VPS.

## The failure mode

**Obsidian Sync is application-driven on Windows.** Merely writing a file into the
Windows vault folder does NOT upload it while the Obsidian desktop app is closed —
the sync engine only runs when the app is open. So a laptop-side note can exist on
disk for hours and never reach the remote (and thus never reach VPS2), while VPS2's
`ob-sync.service` stays healthy and reports "Fully synced" every 30s the whole time.

This is the same class of miss the Patchi handoff flagged: an agent (Hollow) writes
a durable record laptop-side (in its own OpenClaw workspace / the vault folder)
but the shared-vault artifact never lands because the upload never happened.

## Diagnosis nuance

Agents may mis-report the daemon as absent when it is actually installed as a
*system* service — check both:
`systemctl status ob-sync.service` (system) — not just user services — before
concluding sync is down.

## Fix

Open **Obsidian on the laptop** to trigger the upload; the file then lands on VPS2
within ~30s. Do not chase sync lag, do not suspect VPS2 first, do not rebuild the
file from memory — the source exists; it just needs its app running.

If the laptop is reachable on the tailnet but SSH/Tailscale-SSH are closed, you
cannot pull the file from VPS2 — the human must open the app (or grant SSH access).
