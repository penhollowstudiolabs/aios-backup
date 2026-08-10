---
name: tailscale-networking
description: "Avi's Tailscale net: SSH, node rename, Taildrop, onboarding."
version: 1.0.0
metadata:
  hermes:
    tags: [tailscale, networking, vps, infrastructure, ssh, taildrop, magicdns]
---

# Tailscale networking for the AIOS fleet

Avi runs a private Tailscale overlay tying together his machines so they talk
over encrypted Tailscale IPs / MagicDNS names instead of the public internet.
This skill is the operating guide for that net. Current topology and dated
command recipes live in `references/tailnet-operations.md`.

## When to use
- Adding/renaming/onboarding any device (VPS1, VPS2, `avi-laptop`, iPhone).
- Enabling or verifying **Tailscale SSH** on a node.
- Moving an SSH connection from a public IP to the tailnet (MagicDNS name).
- **Taildrop** file handoff between machines.
- Deciding whether `tailscale serve` / `funnel` / ACLs / exit node are warranted.

## Core invariants & style
- **Name nodes with clear stable slugs** (e.g. `aios`, `ilocos`, `avi-laptop`),
  not the OS default hostname (`srv1788663`, `DESKTOP-…`).
- Prefer **MagicDNS hostname** when connecting, **not the raw Tailscale IP** —
  the IP path hits strict host-key failures on a fresh known_hosts (see pitfalls).
- Onboarding a device = install the Tailscale app + sign in with the tailnet
  owner account (`avipenhollow@gmail.com`). No manual config.
- Keep changes **reversible and non-destructive**: Tailscale SSH is additive
  (public OpenSSH on :22 is untouched). Only shut off public SSH with explicit
  Avi go-ahead, after the replacement path is verified.

## Taildrop vs Telegram — the lane rule
Avi drops files in Telegram "all the time"; that is the correct default and he
should NOT be pushed off it. Taildrop is the specialized lane for when Telegram
is the wrong tool. Decision rule:
- **Telegram (default):** small files (doc, screenshot, brief) that are part of
  the conversation and the agent should see/use; reference material that should
  sit in the chat thread. Speed of context wins.
- **Taildrop (when Telegram is wrong):**
  - *Large/heavy* files — videos, archives, exports, DB dumps. Telegram
    compresses media and has size ceilings; Taildrop is byte-identical.
  - *Sensitive* — raw student FERPA records, financial files. Telegram sits on
    TG servers and gets pulled into agent cloud context; Taildrop is
    device-to-device over the tailnet and never touches model context. (Rule:
    raw FERPA PII never to cloud models.)
  - *Machine-to-machine / automated* — a VPS pushing a backup or artifact.
  - *Not intended for chat* — binaries/dumps that would pollute context.
- The durable card capturing this lives at
  `Atlas/_Inbox/2026-08-06 - File Handoff - Telegram vs Taildrop - Which Lane Card.md`,
  and the Daily Brief carries a one-line reminder pointing at it.
- **iPhone Taildrop receiver verified live 2026-08-06** (aios → avi-iphone): first
  receipt on a new device may require tapping "Accept" in the Tailscale app; file
  lands in the iOS Files app under Taildrop. Works both directions once accepted.

## Key commands
```bash
tailscale set --ssh                         # enable Tailscale SSH on a node
tailscale set --hostname=<slug>             # rename a node (MagicDNS + IP unchanged)
tailscale status                            # human view (authoritative for names)
tailscale status --json                     # machine view (JSON may lag on rename)
tailscale file cp <src> <node>:             # Taildrop push to <node> (colon = default)
```

## Pitfalls (learned)
- `tailscale set --ssh` on a node you are SSH'd into OVER the tailnet aborts
  with a `lose-ssh` risk warning ("this will reroute SSH traffic and disconnect").
  Re-run with `--accept-risk=lose-ssh`; openssh stays up so you can reconnect.
- Connecting by **raw IP** yields `Host key verification failed` when only the
  hostname key is in known_hosts. Connect by magicDNS name with
  `-o StrictHostKeyChecking=accept-new`, or add the IP key explicitly.
- `tailscale status --json` can report the OLD node name for a while after a
  rename; `tailscale status` (plain) reflects the new name immediately. Trust plain.
- The `tailscale ssh` wrapper is finicky about host keys on first run; per
  Tailscale's own docs, plain `ssh root@<name>` over the tailnet is the normal path.
- `tailscale set --hostname` runs Server-Side on the node; do it from that node
  (or via SSH to it), not arbitrarily from another box.
- **Node shows `offline, last seen Xm ago` — it may just be powered off, not
  broken.** After a laptop power-off/reboot, `tailscale status` shows offline
  until the machine boots AND the Tailscale app reconnects (app auto-starts
  with Windows; usually nothing to do). Confirm recovery with
  `tailscale ping <node>` → `pong` — a pong is the ground truth that it's back
  on the net. Don't assume a power-cycle broke the node config; the app
  reconnects automatically once the machine is up.

## Later-use (don't build now)
- `tailscale serve` — expose an internal service to the tailnet only.
- `tailscale funnel` — expose publicly via Tailscale HTTPS (needs a real service first).
- **ACLs** — the dial to turn when a SECOND human ever joins (single-human net
  currently defaults to everyone-reach-everyone).
- **Exit node** — route a device's traffic out through a VPS for untrusted wifi.
- Agent-to-agent comms (the parked Buzz/ACP-direct lane) run most cleanly over
  the tailnet rather than public ports.

See `references/tailnet-operations.md` for the current topology and exact recipes.
