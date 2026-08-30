# Obsidian Sync is application-driven on Windows (cause confirmed 2026-08-29)

## The failure
A note was written into the Windows vault folder
(`C:\Users\Owner\Documents\Captain Avi Vault\Atlas\_Inbox\...`) but never appeared
on the VPS2 side (`/root/vault`), even though the headless `ob-sync.service` on
aios was healthy and reporting "Fully synced" every 30s.

## Root cause
**Obsidian Sync is application-driven on Windows.** Writing a file into the vault
*folder* while the Obsidian desktop app is **closed** does **not** upload it —
the app only syncs when it is running. The VPS daemon is pull-on-interval: it can
only fetch what the origin device actually uploaded. Nothing was wrong on the VPS
side; the laptop never uploaded because the app was closed.

## Diagnostic distinction (the key read)
- VPS side healthy + synced ≠ the remote has the file. The bottleneck is almost
  always the **origin device's upload**, and on Windows that upload requires the
  Obsidian desktop app to be running.
- This is different from the 8/28 case (origin confirmed both files present but
  the vault showed none). The 8/29 cause is narrower and very common: **app
  closed at write time** → file sits in the folder un-uploaded.

## Resolution
Open the Obsidian desktop app on the laptop (let it sync). The VPS should receive
the note within ~30s. Verify by re-checking the sync log's download lines for the
new filename, then read the note.

## When to suspect this
A user says "another agent / I just added a file to the vault" but it's not on the
VPS, and the aios sync daemon is healthy. Before assuming a deeper problem, ask
whether the Obsidian app was actually open on the origin device at write time.

See `references/obsidian-headless-sync.md` for the general diagnostic sequence.
