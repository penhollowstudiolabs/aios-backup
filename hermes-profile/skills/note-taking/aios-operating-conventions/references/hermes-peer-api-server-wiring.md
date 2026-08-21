# Hermes Peer / API Server Wiring (VPS1 ⇄ VPS2)

Goal state on Avi's AIOS: the two VPSes (and eventually the laptop-local profile)
can sit in one Desktop roster and DM each other directly. This captures the
working config and — more importantly — the pitfalls that cost time.

## End state (built + verified 2026-08-21)

- Both VPSes run a persistent `api_server` bound to the **tailnet IP only**
  (NOT public internet), auth'd by a shared `API_SERVER_KEY`, registered as
  mutual `hermes peer`s.
  - VPS2 aios (Alyosha/me): `http://100.78.203.127:8642`
  - VPS1 ilocos (Mayumi):   `http://100.86.81.127:8642`
- Verified: both `/v1/models` return 200 with the Bearer key;
  `hermes peer dm ilocos` from VPS2 → Mayumi replied (real cross-VPS agent DM).

## Where config lives

- `API_SERVER_ENABLED / HOST / PORT / KEY` — in each profile's
  `~/.hermes/profiles/<profile>/.env` (e.g. VPS2 uses
  `/root/.hermes/profiles/alyosha/.env`, NOT `/root/.hermes/.env`).
- Peer registry via CLI (`hermes peer add <name> --url http://host:port --key <KEY>`);
  peer key stored as `HERMES_PEER_<NAME>_KEY` in `.env`, names/URLs in
  `config.yaml` under `bot_peers`.
- A single shared key across both VPSes is acceptable here (private tailnet).

## Pitfall: WHICH gateway are you restarting? (cost Avi several tries)

- The gateway serving Alyosha's Telegram conversation is the **`alyosha` profile**
  on VPS2, hand-launched — it is **NOT** the default profile and **NOT** a
  systemd unit. `hermes gateway restart` and `systemctl restart hermes-gateway`
  target the wrong thing and silently do nothing to it.
- **Correct restart for the alyosha profile:** `hermes -p alyosha gateway restart`
  (restarts the actual user service; PID changed 275639 → 605656).
- VPS1's gateway IS a proper systemd unit `hermes-gateway-ilocos.service` and
  restarts fine via `systemctl restart hermes-gateway-ilocos` or `hermes update`.
- The `alyosha` process is tracked in gateway_state.json but that file goes stale
  (it referenced an old PID 216407 while 275639 was live) — trust `ps` for the
  real PID, not the state file.

## Pitfall: the in-gateway restart guard

The Hermes tooling running *inside* the gateway process hard-blocks ANY command
that restarts/stops a gateway — including `ssh root@ilocos 'systemctl restart
hermes-gateway-ilocos'` — because it can't tell you're aiming at a different
machine and SIGTERM would propagate. Do not fight it; hand the restart to Avi to
run from a separate shell (laptop / outside the gateway).

## Deploy order that works

1. Stage `.env` vars on both boxes (no disruption) — idempotent append.
2. Register the peer on each box (`hermes peer add ...` — non-destructive).
   - VPS1 must be on a Hermes build that HAS the `peer` subcommand; an old
     build (v0.20.0) lacks it → update VPS1 first (`hermes update`) then add.
3. Restart each gateway so `api_server` binds (the only disruptive step).
4. Verify: port open on tailnet IP + `curl /v1/models` with key returns 200 +
   a `hermes peer dm` round-trip.
