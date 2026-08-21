# Hermes fleet — multi-machine bot-mode / remote-access readiness

> State as of 2026-08-21. Re-verify the live state of each node before trusting
> these specifics; the audit recipe is durable, the exact procs/ports may drift.

## Goal context
Avi wants the three Hermes agents (me/Alyosha on VPS2 `aios`, Mayumi on VPS1
`ilocos`, and a future local profile on `avi-laptop`) working **together in one
Hermes Desktop roster**, with agent↔agent DMs — and remote access when the home
(laptop) machine is off. He chose **laptop-as-hub** (not VPS2-as-hub): the
desktop app stays the primary surface; VPSes are secondary gateways.

## Two different process shapes on a Hermes node (THE key diagnostic)
Do not confuse these — they have opposite implications:

- **`hermes gateway run`** — the *persistent agent gateway*. A real always-on
  process carrying the profile's platform credentials (Telegram token, etc.).
  A node that runs one is a live agent even with no laptop attached. Both VPSes
  have this (VPS1 since ~Aug 16).
- **`hermes serve --isolated --host 127.0.0.1 --port 0 --ssh-session-token-file ... --ssh-owner-nonce ...`** —
  an *ephemeral, loopback-bound SSH tunnel* opened on demand by Hermes Desktop
  on the laptop to reach a remote box. Loopback-only = **not** a reachable API
  backend. The laptop Desktop opens these automatically when you connect.
  Their presence proves the **laptop → node connection works**, nothing more.

## The capability gaps that matter for bot-mode
Three things require a **persistent, tailnet-reachable `api_server` platform**,
NOT the desktop-opened tunnels:

1. Registering a node as a *remote connection* in a multi-gateway roster.
2. **`hermes peer dm`** bot-to-bot DMs between machines — needs the remote box
   running `api_server` with a strong `API_SERVER_KEY`, plus the sender has the
   peer registered (`hermes peer add <name> --url <url> --key <key>`; peers/keys
   stored as `bot_peers` in `config.yaml` + `HERMES_PEER_<NAME>_KEY` in `.env`).
3. Reaching the roster from the **web dashboard** on a device that isn't the hub.

### Verified audit result 2026-08-21
- `aios` (VPS2): gateway running; laptop has live `serve --ssh-owner-nonce`
  sessions = **laptop→Alyosha connected**. NO `api_server`, NO `bot_peers`,
  NO `HERMES_PEER_*` keys.
- `ilocos` (VPS1): persistent `hermes gateway run` since ~Aug 16; laptop also
  has a `serve` tunnel open. Same gaps: NO `api_server`, NO `bot_peers`/keys.
  Only listening hermes port was `127.0.0.1:42065` (loopback ephemeral).
  Also runs `iron-proxy` (residential egress for Amazon/commerce — unrelated).
- Both VPSes reachable over the tailnet (`tailscale ping ilocos`: pong ~6ms;
  ssh `root@ilocos` works with the key already on VPS2). So the **network layer
  is fully done**; the only remaining work is the API-server config on both boxes.
- Node identities: **VPS1 agent is Mayumi** (profile `ilocos`) — *not* Kathleen.
  Kathleen is the person (Avi's wife, engages VPS1 commerce side only). Do not
  call the VPS1 agent Kathleen.

## Audit recipe (run per node, over tailnet SSH)
```bash
# 1) profiles present
ls ~/.hermes/profiles/
# 2) api_server / serve / bot_peers / multiplex present in config?
grep -iE "api_server|serve|bot_peers|gateway|port|multiplex" ~/.hermes/config.yaml
# 3) peer / api keys in .env? (values redacted)
grep -iE "HERMES_PEER|API_SERVER" ~/.hermes/.env
# 4) which hermes processes are running (gateway vs ephemeral serve)
ps aux | grep -iE "hermes|gateway|serve" | grep -v grep
# 5) what ports are actually listening (127.0.0.1 = loopback/ephemeral)
ss -tlnp | grep -iE "hermes|node"
```

## Why api_server wasn't stood up until now (context)
`hermes serve` behind a non-loopback address is a **real exposed surface** —
a listening port reachable over the tailnet, guarded only by an API key. Having
every node loopback-only until now was the safest possible posture, and it was
**sufficient** because the hub was always the laptop-online-in-front-of-you.
Telegram already moved messages agent↔agent, so there was no bot-to-bot gap.
The API-server layer only becomes worth the cost once you actually want remote
access + direct DMs + a networked roster. That need arrived this session; the
user has authorized turning on `api_server` on both VPSes (config not yet made
by the foreground session).

## Enablement shape when we get to it
- On each VPS: enable the `api_server` platform, bind it to a tailnet-reachable
  address, set a strong `API_SERVER_KEY` in `.env`.
- Generate a peer key pair; add `bot_peers` entries (`HERMES_PEER_<NAME>_KEY`)
  to each box so the agents recognize each other.
- Restart each gateway. After: laptop Desktop shows both VPS bots in one roster;
  `hermes peer dm` works between me and Mayumi; dashboard reachable from any
  device when the laptop is off.