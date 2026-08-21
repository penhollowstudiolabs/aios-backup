# api_server platform + hermes peer — byte-level detail

Verified against Hermes Agent v0.20.x source (git install at `/usr/local/lib/hermes-agent`) on 2026-08-21 while wiring VPS2 (`aios`) ↔ VPS1 (`ilocos`).

## Config keys (`.env` — settings, credentials live here, NOT config.yaml)
Defined in `hermes_cli/config_defaults.py`:

| var | purpose | default |
|---|---|---|
| `API_SERVER_ENABLED` | enable the OpenAI-compatible API server platform | (unset/off) |
| `API_SERVER_KEY` | **Bearer auth; REQUIRED — the platform refuses to start without it** | none |
| `API_SERVER_HOST` | bind address | `127.0.0.1` |
| `API_SERVER_PORT` | listen port | `8642` |
| `API_SERVER_CORS_ORIGINS` | CORS allowlist | empty/off |
| `API_SERVER_MODEL_NAME` | model advertised on `/v1/models`; defaults to profile name | profile name |

`secret_scope.py`: `API_SERVER_ENABLED/HOST/PORT/CORS_ORIGINS` are **non-secret** (read by the scoped runner reload); `API_SERVER_KEY` is deliberately a **credential** and stays out of the non-secret scope.

## Platform enablement
`gateway/platforms/api_server.py`:
- `DEFAULT_HOST = "127.0.0.1"`, `DEFAULT_PORT = 8642`.
- `connect()` refuses to start without `API_SERVER_KEY`.
- Source of truth for valid keys on the gateway: `gateway/run.py` treats the API server as a non-messaging platform loaded **at gateway startup** — so enabling it requires a gateway restart (not hot-reloadable).
- `gateway/run.py` fabricates one schedule → notes "most common cause nopport_key missing from this process's environment".

## `hermes peer` CLI
`hermes_cli/subcommands/peer.py`:

- `hermes peer add <name> --url http://<host>:<port> --key <API_SERVER_KEY>` — saves `bot_peers` entry in `config.yaml` and stores the key in `~/.hermes/.env` as `HERMES_PEER_<NAME>_KEY` (name upper-cased, `-` → `_`, then `_KEY`).
- `hermes peer list` — shows registered peers + `[key set]`/`[no key]`.
- `hermes peer dm <peer>[/<agent>] "<message>"` — delivers a temp-file message into the remote agent's canonical Bot Chat over its API server, runs one turn, prints the reply. Cross-machine twin of `hermes -p <bot> chat -Q --query-file …`.
- Exit codes: `0` ok, `1` delivery/peer error, `2` usage.

## Version gate (important)
The `peer` subcommand is NOT present in older builds. Seen this session:
- **v0.20.0 (2026.8.3)** → `hermes peer` → `invalid choice: 'peer'` (no `peer.py` in the CLI). Must `hermes update` first.
- **v0.20.4 (2026.8.18)** → `peer` present.

Check with `hermes --version` before registering a remote peer.

## In-flight state (Avi's fleet, end of session)
- VPS2 `aios`: api_server env staged (enabled/key/host `100.78.203.127`/port 8642), peer `ilocos` registered.
- VPS1 `ilocos`: updated to latest build (had `hermes update` run), api_server env staged (host `100.86.81.127`), peer `aios` registered.
- **Not yet done:** the per-box gateway restart that actually binds the listener (must run from a shell outside the gateway; the in-gateway terminal is hard-blocked). After restart, verify `ss -tlnp | grep 8642` and `hermes peer dm`.
- Pre-existing VPS1 config warning (unrelated): `AGENTMAIL_API_KEY` placeholder unset in `~/.hermes/profiles/ilocos/.env` — not part of this task.