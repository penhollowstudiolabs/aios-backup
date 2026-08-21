# Vault sync incident response — folder moves, duplicates, empty shells (2026-08-08)

When a drag in Obsidian's sidebar moves folders (Efforts, Clippings) or sync
artifacts appear (duplicate folders, empty shells), the fix pattern below is
proven. The vault is a bidirectional Obsidian write-peer (`ob-sync.service`,
continuous ~30s ticks) — a fix on aios propagates to cloud → laptop → iPhone.

## 1. Diagnose from the ob-sync journal (don't guess from the screenshot)

```bash
ls -lat /root/vault | head -30          # top-level mtimes reveal what changed
find /root/vault -maxdepth 2 -type d -name "<name>"   # locate moved dirs anywhere
journalctl -u ob-sync --since "30 min ago" --no-pager | grep -E "Push|Delet|Download|Accepted"
```

The laptop's drags arrive as `Push:` / `Deleting remote` / `Downloading ...`
lines with paths. A moved folder will appear NESTED under its drop target
(e.g. `Business/Efforts` or `People/Efforts`).

## 2. Back up before touching anything

```bash
mkdir -p /root/vault-backups
tar czf /root/vault-backups/efforts-incident-$(date +%Y%m%d-%H%M%S).tar.gz \
  -C /root/vault Efforts People   # affected top-level folders only
```

## 3. Identify shells vs real content

Near-empty top-level copies (1 file) are stale remnants; the freshly-synced
nested copy (many files, newest mtimes) is authoritative. Compare:
`diff -rq <shell> <real>` and `find <dir> -type f | wc -l`.

## 4. Merge

- Unique dirs: `mv /src/* /dst/` works.
- Name-colliding dirs: `mv` refuses ("Directory not empty") — use
  `rsync -au /src/ /dst/` (adds missing, overwrites only when newer), then
  `rm -rf /src`.
- After rsync, verify: `diff -rq /src /dst` should show nothing "Only in /src".

## 5. Push and confirm

```bash
sleep 40; journalctl -u ob-sync --since "2 min ago" --no-pager | grep -iE "delet|push|fully synced"
```

Expect `Deleting remote folder ...` / `Push: ... (deleted)` / `Fully synced`.

## 6. User side

Have Avi **fully quit and reopen Obsidian** on the laptop (close window /
Alt+F4 on Windows — NOT Cmd+Q; his laptop is not a Mac). Obsidian pulls the
corrected state within ~30s. If an empty `People`-style shell reappears,
right-click → Delete it; sync clients can re-materialize empty dirs (harmless,
0 files — verify with `find <dir> -type f | wc -l` before deleting).

## Gotchas

- `mv` of a dir onto an existing dir of the same name merges CONTENTS only for
  files; it fails on non-empty subdir collisions → rsync is the reliable merge.
- Do not remove a top-level folder that pre-existed (e.g. `People` was original
  structure) just because it's empty after the fix — leave it; Obsidian hides
  empty folders.
- The "Update links" popup (Obsidian asking about N links in M files): advise
  "Just once". Keep "Automatically update internal links" ON — off means links
  break silently on future moves.
