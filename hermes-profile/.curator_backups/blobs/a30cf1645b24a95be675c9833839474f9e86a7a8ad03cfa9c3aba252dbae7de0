---
name: hermes-multi-machine-link
description: "Use when linking Hermes agents across machines."
version: 1.0.0
author: Alyosha
license: MIT
platforms: [linux, windows]
metadata:
  hermes:
    tags: [hermes, bot-mode, api-server, bot-peers, multi-agent, cross-machine, desktop, tailnet]
---

# Linking Hermes Agents Across Machines

## When to use
- Wiring Hermes profiles that live on **different machines** (e.g. VPS2/aios + VPS1/ilocos + a Windows laptop-local profile) so one Hermes Desktop shows them in a single Bot roster and bots can DM each other.
- Enabling `api_server` on a remote box, registering bot peers, or diagnosing why cross-machine bot-to-bot DMs don't work.
- Any plan to make an agent reachable beyond its loopback for remote/Desktop use.

This is the *cross-machine* companion to the bundled `hermes-agent` skill (which covers the general feature surface — Bot Mode/Desktop). Read this for the config-and-pitfall layer; do NOT duplicate what the bundled skill already documents.

## Mental model (from the docs, verified this session)
- **A Bot is a profile.** Bot Mode is a UI over `~/.hermes/profiles/<name>/` — there is no separate "bot" primitive. Everything a Desktop roster shows is just a profile on some backend.
- **One Desktop, many backends.** Register every backend (local runtime, remote gateway over LAN/Tailscale, SSH, Hermes Cloud) in Settings → **Gateways** → connections. The Bot roster is the union of all registered sources; handles disambiguate as `@name-device` when a name exists on several machines.
- **Cross-machine @mentions / rooms** route over the connection registry in the background. Bot-to-bot DMs (`hermes peer dm`) use each gateway's `api_server` directly, no desktop in the loop.

## Topology pattern that worked (Avi's fleet)
- **VPS2 (`aios`)** — Alyosha (this agent). Persistent `hermes gateway run`, reachable by Desktop over SSH-through-tailnet.
- **VPS1 (`ilocos`)** — Mayumi. Same shape (persistent gateway, profile `ilocos`).
- **Laptop (`avi-laptop`)** — the Hermes Desktop hub. Connects to both VPSes over SSH; a local Hermes profile is the planned *third* location.
- The tailnet (one account `avipenhollow@gmail.com`) is the reachability backbone: see `tailnet-infrastructure` for network-level hardening. Bind `api_server` to each box's **tailnet IP**, never `0.0.0.0`, so nothing is exposed to the public internet.

## Operation: enable `api_server` + a peer on a host
1. **Bind + auth via `.env`** (settings live here, not config.yaml):
   ```
   API_SERVER_ENABLED=true
   API_SERVER_HOST=100.78.203.127        # tailnet IP of THIS box
   API_SERVER_PORT=8642                  # default 8642 if omitted
   API_SERVER_KEY=<strong random token>  # required; server refuses to start without it
   ```
   `API_SERVER_ENABLED/HOST/PORT/CORS_ORIGINS` are read from `.env`; `API_SERVER_KEY` is a credential (in the secret scope).
2. **Register the peer** (VPS2-ward calls to VPS1; reverse on VPS1):
   ```
   hermes peer add <name> --url http://<tailnet-ip>:8642 --key <same shared key>
   ```
   This writes `bot_peers` into config.yaml and `HERMES_PEER_<NAME>_KEY` into `.env`. A single shared strong key is fine for a private tailnet with a couple of nodes; treat it as the tailnet's own secret, not a per-machine split.
3. **Restart the gateway** to bind the listener — `api_server` loads as a platform at gateway startup; it is NOT hot-reloadable. `hermes peer dm <peer>[/<profile>] "<msg>"` then delivers into the remote's Bot Chat and prints the reply.

## PITFALLS (all learned the hard way this session)
1. **The `peer` subcommand is version-gated.** v0.20.0 (Aug 2026) shipped WITHOUT `peer.py` in the CLI ("invalid choice: 'peer'"). Check `hermes --version` first; update the remote box if it lacks `peer` (`hermes update`) before registering it. VPS1 needed this update; VPS2 (v0.20.4) already had it.
2. **A running gateway cannot restart itself.** `hermes gateway restart` (and even `systemctl restart hermes-gateway-<node>` issued *from inside a gateway-side terminal*) is hard-blocked with "cannot restart or stop the gateway from inside the gateway process". The guard treats any such command as self-SIGTERM, even across an `ssh`. The restart MUST come from a shell outside the gateway (laptop Desktop, or the user's own SSH terminal). Don't burn attempts fighting the guard — hand the restart to the user's shell; it's by design.
3. **VPS update safety.** `hermes update` on a remote host stops the dashboard `serve` process and restarts it automatically (one process churn). If an agent's messaging lane depends on the gateway, time the update/restart when the user is not actively working, or get explicit sign-off first.
4. **Staging is reversible; only the gateway restart is disruptive.** Appending `.env` keys and `hermes peer add` idempotently *without* restarting never takes the box offline. Stage everything, verify env/peer state, THEN restart once.

## Verify state
- `hermes peer list` on each box shows the other side (e.g. `aios http://<tailnet-ip>:8642 [key set]`).
- Grep the `.env` for `API_SERVER_*` (values set).
- After restart: `ss -tlnp | grep 8642` shows the listener bound to the tailnet IP.

## Byte-level detail
For the exact config keys, `.env` var list, `peer.py` / `api_server.py` defaults (host 127.0.0.1, port 8642), and source paths: `references/api-server-and-peers.md`.
For reachability / SSH lockout on the underlying tailnet: `tailnet-infrastructure`.