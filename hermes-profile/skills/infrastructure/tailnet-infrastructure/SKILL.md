---
name: tailnet-infrastructure
description: "Use for Tailscale tailnet and public-SSH hardening."
version: 1.0.0
author: Alyosha
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [tailscale, tailnet, vps, ssh, networking, hardening, ubuntu, systemd]
---

# Tailnet Infrastructure (Tailscale on the Avi/AIOS fleet)

## When to use
- Adding, renaming, or verifying a node/device on the tailnet (VPSes, laptop, phone, future iPad).
- Enabling Tailscale SSH, Taildrop file handoff, or pointing a client/service at a tailnet name instead of a public IP.
- Hardening: stopping public SSH exposure while keeping private tailnet access (READ `references/ssh-socket-activation-lockdown.md` first).

## Fleet context
- Tailnet owner: `avipenhollow@gmail.com`. All nodes must join under this ONE account — a device under a different account is a separate tailnet.
- Nodes: `aios` (VPS2), `ilocos` (VPS1), `avi-laptop` (Windows), `avi-iphone` (iOS). iPad deliberately parked (not onboarded).
- Durable state capture lives in the vault: `Atlas/_Inbox/2026-08-05 - Tailnet State - Capture.md`.
- Key-op context: single-human-operator threat model; prefer proportionality, no theatrical security. Avi only wants tighter controls (ACLs) if/when a second human joins.

## Core workflows

### Onboard a device
1. Install Tailscale app → sign in with `avipenhollow@gmail.com` → registers as a new node (owner may need to approve first join).
2. Name it with a clean lowercase-hyphen name (e.g. `avi-laptop`). Rename via admin console → Machines → ⋯ → Rename, or on the node: `tailscale set --hostname=<name>`. OS hostname ≠ Tailscale node name.

### Verify from a server
- `tailscale status` = live human view (trust this after a rename).
- `tailscale status --json` = cached peer records; can lag on renames. Prefer human view for "did the rename stick."

### Enable Tailscale SSH (servers)
- `tailscale set --ssh` — additive; leaves public OpenSSH untouched.
- The `tailscale ssh` wrapper hits a first-connect host-key strict-check quirk under some setups; the normal, recommended path is plain `ssh root@<node>` over the tailnet (MagicDNS/IP).

### Taildrop file handoff
- Send: `tailscale file cp /path <node>:`
- Receive on Windows lands in `C:\Users\<user>\Downloads\Taildrop` (first receive may prompt to accept). This is the no-folder-hunting handoff path.

### Point a client at a tailnet name instead of public IP
- MagicDNS resolves `<node>` → tailnet IP. Swap an SSH host field from the public IP to the node name so all traffic rides the private overlay.

### Lock public SSH to tailnet-only (Ubuntu/Debian)
- sshd runs under **systemd socket activation** (`ssh.socket`); a **systemd generator derives the socket bind from `sshd_config` `ListenAddress`**.
- Correct lever: add `ListenAddress` (IPv4 + IPv6 tailnet addrs) to a `sshd_config.d` drop-in → `systemctl daemon-reload` → `systemctl restart ssh.socket`. Do NOT also drop a manual `/etc/systemd/system/ssh.socket.d/` override (see Pitfall 3).
- Full recipe + fail transcripts + verify: `references/ssh-socket-activation-lockdown.md`.

## Pitfalls (all learned the hard way)
1. Under socket activation, `sshd_config` `ListenAddress` is only read by the *generator* — you must bounce `ssh.socket`, not just `sshd`.
2. `systemctl reload ssh` (SIGHUP) does NOT rebind listening sockets; use `restart`.
3. **Never dual-configure the socket** (generator output + manual override with the same ListenStreams): duplicate bind → "Address already in use" → socket fails → **SSH fully down**. Local console/terminal on the box still works, so you can recover, but it's avoidable.
4. Renames apply to `tailscale status` immediately but lag in the JSON/admin cache — don't "fail" a rename on cached data.
5. Before locking public SSH, confirm nothing depends on public-IP SSH (cron/rsync to the public IP) and that clients (e.g. Hermes Desktop) already use tailnet names, so you don't orphan access.
   - **Real incident (8/7):** aios was locked to tailnet-only while Hermes Desktop's saved SSH host still pointed at the public IP → desktop failed with "SSH connection failed"; desktop.log showed endless `connecting (no-mux) to root@<PUBLIC_IP>:22` and never `aios`. Fix: desktop Gateway settings → host = tailnet name `aios` (or tailnet IP), or click "Use local gateway" for a self-contained laptop-local backend (no SSH/tailnet, but not the VPS agent). Desktop persists this in its Electron userData `connection.json` (SSH block: host/user/port/keyPath/remoteHermesPath/remoteProfile).

## Verify after any SSH lockdown change
- `ss -tlnp | grep ':22 '` → only tailnet IPs, never `0.0.0.0:22` / `[::]:22`.
- `timeout 5 bash -c 'cat < /dev/null > /dev/tcp/<PUBLIC_IP>/22'` → Connection refused (CLOSED).
- `timeout 5 bash -c 'cat < /dev/null > /dev/tcp/<TAILNET_IP>/22'` → succeeds (OPEN).
- `ssh -o BatchMode=yes root@<tailnet-ip> 'echo ok'` → works.
- Confirm vault/obsidian sync unaffected (it rides Obsidian's cloud, not SSH).

## Later-use (don't build now; note the door)
- **ACLs** — tighten "who can reach what" the day a second human joins.
- **Serve / Funnel** — expose an internal service (Listmonk, Hermes dashboard) when there's a service to point at it.
- **Exit node / subnet router** — only if a concrete privacy on untrusted-wifi use case appears.
