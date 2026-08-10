# Worked example: the VPS Obsidian sync fix done from two ends

The failure this pattern prevents, observed with Avi on 2026-08-05.

## Context

Avi runs multiple agents on a shared infra:
- **Alyosha** — Hermes profile on VPS 2 (aios), the continuity/workbench agent.
- **Hollow** — a separate agent on the laptop.
- Both can reach VPS 1 and VPS 2 over a Tailscale net. Shared hard drives (the vault, the VPS boxes) mean the two agents' territories overlap.

The vault problem being fixed: VPS 1 is the Obsidian Sync authority (`ob sync --continuous`); VPS 2 ran a one-way `rsync --delete` mirror, so any vault file Alyosha wrote to VPS 2 got wiped on the next pull. Fix = install a real `ob sync` node on VPS 2 (authored by Hollow) + a fresh device token (user-only).

## What went wrong (my side)

1. Hollow sent Avi a plan: copy the `ob` binary from VPS 1 → VPS 2, then Avi provides a fresh token, then Hollow finishes setup.
2. I (Alyosha), in the same session, independently SSH'd and discovered the binary was **already installed**.
3. I immediately jumped to verify config, confirm the gap, and push the fix forward — **overlapping Hollow's lane** and executing the terminal side of a task Hollow owned.
4. Avi corrected me: "Hollow is the one who started the process... we are working at this from two ends. Not a problem but let's keep the turns calibrated."

## The correct behavior (what to encode)

- I should have **handed the "binary is already there" finding to Avi as intel for Hollow**, not taken over the terminal steps.
- I should have asked "do you want me to take this, or is Hollow completing it?" before acting.
- Avi's stated convention: **"One agent at a time per task, unless you say otherwise."**

## The small "who can do what" table that helped Avi

| Thing | Alyosha (VPS2) | Hollow (laptop) | User |
|-------|:---:|:---:|:---:|
| See/modify VPS1 | ✅ SSH | depends | — |
| See/modify VPS2 | ✅ lives here | depends | — |
| Touch laptop files | ❌ | ✅ | ✅ |
| Generate Obsidian sync token | ❌ | ❌ | ✅ only |
| Install packages on VPS | ✅ | maybe | — |
| Authorize devices / accounts | ❌ | ❌ | ✅ only |

Pattern to reuse: **credentials + account actions = user; machine actions = whichever agent has access; decisions = user, always.** Present this as a table when the user is learning the system.

---

## The actual `obsidian-headless` sync procedure (the fix, concretely)

The two-end reference file above described the *goal*, but if a future session needs to actually land this, the working method is:

**Key correction that saved the day:** `obsidian-headless` does NOT use an Obsidian Sync "device token" generated in the desktop app. The earlier plan ("go to Settings → Sync → devices → generate token") was wrong for this tool. It authenticates by logging into the Obsidian **account** with `ob login`, then attaching to an existing **remote vault** by name. Do not send the user hunting for a device token; the desktop-app device mechanism is unrelated to the headless CLI.

```bash
# confirm installed (it's an official obsidianmd package, symlink /usr/bin/ob -> .../obsidian-headless/cli.js)
ob --version

# 1. interactive account login (email/password/2FA) — THE credential step. User should type
#    the password themselves into the terminal, not paste it into chat.
ob login

# 2. list remote vaults to confirm the exact vault name string
ob sync-list-remote

# 3. point this node at the existing vault and set it up
cd /root/vault
ob sync-setup --vault "Captain Avi Vault"   # exact name from step 2

# 4. run continuously (watches for changes) — run under a systemd service so it survives reboots
ob sync --continuous --path /root/vault
```

Auth state lands in `/root/.config/obsidian-headless/auth_token` (created by `ob login`). Notes:
- **The binary may already be installed** — check before copying; `which ob` can miss a symlink in some shell contexts, so verify with `ls -la /usr/bin/ob`.
- **Sequencing guard:** leave the old `rsync --delete` mirror running until the new `ob sync` node is verified as a live, *writing* peer — never remove the only sync path to create a window with none. This is a read-only mirror → real-peer migration.
- Package is official (`github.com/obsidianmd/obsidian-headless`) — safe to trust, not a sketchy community tool.

