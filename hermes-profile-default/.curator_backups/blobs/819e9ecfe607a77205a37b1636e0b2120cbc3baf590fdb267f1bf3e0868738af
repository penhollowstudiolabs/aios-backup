# Synced-vault file handoff: verify local disk before acting

Scenario that produced this note: a peer agent (Hollow) reported two documents as
"verified present" in the Obsidian vault's `Atlas/_Inbox/` and said it made no changes.
A whole-disk search on the receiving VPS showed the files had NOT landed there yet —
the only 08-28 artifacts present were this machine's own cron outputs. The correct
response was to refuse to move anything and report the mismatch plainly.

## The durable rule

Do not act on a peer's "verified present / made no changes" claim about a synced-vault
file until YOU confirm it exists on your own local filesystem.

- **Obsidian Sync lag is real and can be ~1 day.** A file can be present on the origin
  machine (laptop/desktop) and pushed through Sync, yet not yet pulled down to a VPS
  vault. A peer "verifying" on the origin endpoint does not mean the receiving host has it.
- A handoff card in `Atlas/_Inbox` and a returned-artifact claim are not proof of local
  presence. Presence is proven only by the local read.

## Verification sequence (all before any move/edit)

1. `ls -la` the target inbox and `grep` the expected date prefix / titles.
2. `search_files` / `find` the whole vault for the exact titles and for a date prefix.
3. Whole-disk search (`find / -type f -iname "*<date>*"`) to catch files that landed
   outside the vault (Taildrop drops, ~/Downloads, /tmp) or under another name.
4. Cross-check recent-modified entries to see the last actual sync.

## When the files are not present

- Say so plainly: "the file hasn't landed on this machine; I made no changes."
- Do NOT fabricate the move or claim success for a file that isn't there.
- Offer delivery lanes, and let Avi pick:
  - force a sync pull on the receiving host, then file immediately,
  - ask the origin to push directly (Taildrop / file transfer / direct write), or
  - set a watcher/monitor on `Atlas/_Inbox/` that files the docs on arrival and
    confirms the final paths.
- Until one of those lands the file locally, the filing task stays open.

## Contrast with the existing pitfall

The existing SKILL.md pitfall covers the opposite error: "don't assume a report is
absent just because it isn't in `Atlas/_Inbox` — search the whole vault." This note
covers the mirror: "don't assume a peer-claimed file is present just because the peer
said so — verify local disk first." Both directions matter; neither is the other.
