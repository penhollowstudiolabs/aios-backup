# Hermes Desktop remote-gateway SSH spawn — diagnosis (8/21)

Context: Hermes Desktop on a fleet machine connects to a remote Hermes backend (e.g. a
VPS) over "Connect via SSH". Symptom: desktop shows **"gateway ready"** then
**"waking up <name>"** then the connection flips **offline** again — every retry,
same. Meanwhile the *default/local* profile backend answers instantly. That contrast
(one named profile dies on wake, the default/local one is fine) is the key tell.

## Why the named one dies while default/local doesn't

- Desktop **Connect via SSH** mode spawns a `hermes serve --isolated` scoped to the
  *named profile* on the remote, tunneled back through the SSH session.
- `hermes serve --help` (v0.20.4) is explicit: `--isolated` = "When launched from a
  **named profile**, run a dedicated server scoped to that profile instead of routing
  to the machine-level server."
- The desktop passes `--host 127.0.0.1 --port 0 --ssh-session-token-file <path>
  --ssh-owner-nonce <nonce>`. The nonce is generated/validated by the desktop side and
  rides in the **saved connection record**.
- Backends launched WITHOUT `--profile`/`--ssh-owner-nonce` (the machine-level /
  default path) skip the nonce validation entirely — which is exactly why the default
  profile connects fine while the named one fails: the named spawn hits the nonce check
  and dies at startup.

## The catch — reproduce the spawn, don't reason about the client

Stop theorizing about the desktop side. Run the *exact* serve command the desktop uses,
on the SERVER, by hand, with:
- a throwaway token file written first,
- `--profile <name> serve --isolated --host 127.0.0.1 --port 0`,
- the token + nonce args, and
- stdout/stderr captured.

Observed reproduction:
```
exit 1
stderr: --ssh-owner-nonce must be 16 lowercase hex characters
```
That names the cause squarely: the desktop's stored nonce for that connection is stale or
corrupt — `serve --isolated` validates it on startup, rejects, exits before printing
`HERMES_BACKEND_READY`, the app sees the backend vanish → "waking X" → offline. Same every
retry.

## Indicated remedy (NOT confirmed end-to-end at session close)

In Hermes Desktop: **remove the stale SSH connection for that <name> and re-add it** (Host =
tailnet name or tailnet IP, User, port, explicit key path). A fresh connection record causes
a fresh nonce to be written on the next spawn. This is the operator (Hollow/laptop) lane, not
server-side — hand off the final click rather than grinding.

## Operator-interaction lessons (Avi corrections, 8/18)

Two corrections this session that cost real trust, worth carrying:
1. **Know the node's OS before handing the human steps.** The tailnet records `avi-laptop (Windows)`, and a live `tailscale status` this very session showed it — yet I gave macOS `.dmg` instructions and Apple fixes. For ANY fleet machine, re-read the documented node OS / live `tailscale status` FIRST; default to what's actually recorded, never to the current message.
2. **Don't overstate what you did.** I claimed the leftover default profile had been removed when live server processes still served it. State plainly what actually changed vs what was only intended; if a step never landed, say so directly.

Style habits to avoid: reassuring format with no evidence when the user reports a symptom ("it *should* work"), and offering a "next step" without first probing the server for ground truth. When Avi flags waning patience, the respect is a short, honest, diagnosed step — not a longer apology.

Diagnostic side notes:
- Confirm the SSH user exists server-side (`id <user>`); the app may default the field to the
  laptop's Windows/OS username (`owner`), which is NOT an account on the VPS (`root` is).
- Confirm the resolve target: the app may dial a saved **public IP** even when the Host field
  shows the tailnet name — public :22 is usually firewalled off, tailnet :22 open. Verify
  reachability from the server itself before blaming the network.
- `ps -eo pid,stime,args` for `serve --isolated` + the `desktop-ssh/` lock files tell you which
  live backends actually exist vs which lock record is stale (dead pid still in the lock file).