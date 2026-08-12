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

### Enable / diagnose Tailscale SSH (servers)
- `tailscale set --ssh` — additive; leaves public OpenSSH untouched.
- The `tailscale ssh` wrapper hits a first-connect host-key strict-check quirk under some setups; the normal, recommended path is plain `ssh root@<node>` over the tailnet (MagicDNS/IP).
- **`tailscale status --json` is NOT the authority for whether Tailscale SSH is serving auth.** `Self.SSHEnabled` can read `None` even when SSH is actively intercepting port 22 (the field lags / reflects the ACL, not the daemon pref). Authoritative checks:
  - `tailscale debug prefs` → `"RunSSH": true` is the real daemon-level answer.
  - Wire proof from a client: remote banner `SSH-2.0-Tailscale` + the "To authenticate, visit https://login.tailscale.com/a/…" additional-check prompt = Tailscale SSH is answering on :22, NOT plain OpenSSH. When you see that, no authorized_keys edit will help — auth is being intercepted before OpenSSH is reached.
- Diagnosing "key-based SSH blocked" over a tailnet-only box (8/11 incident): check, in order — (a) TCP to the tailnet IP opens, (b) banner type (Tailscale vs OpenSSH), (c) client host-key in known_hosts, (d) the laptop's key fingerprint is actually in aios `authorized_keys`, (e) `tailscale debug prefs` RunSSH. Fingerprint server keys with `ssh-keygen -lf` on each base64 from `authorized_keys` (field 2), and compare to the client's active + revoked keys — a revoked predecessor key may be present while the active one is too.
- **Fix when Tailscale SSH is the blocker and key auth is wanted:** `tailscale set --ssh=false` on the server returns :22 auth to plain OpenSSH + `authorized_keys`; if the client's active key is already installed, `ssh root@<node>` then just works. Public SSH stays closed (sshd bound to tailnet IPs only). Reversible. Alternative if you must keep Tailscale SSH: complete the additional-check flow on the client instead. Any of this needs Avi's go-ahead (config mutation).

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
- `ss -tlnp | grep ':22 '` → LOCAL bind addresses (column 4) are only tailnet IPs, never `0.0.0.0:22` / `[::]:22`.
- **PITFALL (8/11):** `ss -tlnp | grep ':22 ' | grep '0.0.0.0'` does NOT prove a public bind — every socket shows a peer column of `0.0.0.0:*` / `[::]:*` (the remote wildcard), and a naive grep matches it, falsely reporting "public bind found." Always inspect the **LOCAL bind column** (field 4, e.g. `100.78.203.127:22`), or run an explicit wildcard scan that anchors to the local column: `ss -tlnp | awk '$4 ~ /(^0\.0\.0\.0:22$|^\[::\]:22$)/'` (empty output = no wildcard/public bind). Read the local column, not the peer column.
- `timeout 5 bash -c 'cat < /dev/null > /dev/tcp/<PUBLIC_IP>/22'` → Connection refused (CLOSED).
- `timeout 5 bash -c 'cat < /dev/null > /dev/tcp/<TAILNET_IP>/22'` → succeeds (OPEN).
- `ssh -o BatchMode=yes root@<tailnet-ip> 'echo ok'` → works.
- Confirm vault/obsidian sync unaffected (it rides Obsidian's cloud, not SSH).

## Later-use (don't build now; note the door)
- **ACLs** — tighten "who can reach what" the day a second human joins.
- **Serve / Funnel** — expose an internal service (Listmonk, Hermes dashboard) when there's a service to point at it.
- **Exit node / subnet router** — only if a concrete privacy on untrusted-wifi use case appears.
