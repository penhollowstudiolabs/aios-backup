# Tailnet operations — topology & recipes

> State as of 2026-08-05. Topology is durable-ish but re-verify with
> `tailscale status` before trusting IPs/names in a new session.

## Current topology (2026-08-05)

| Node | IP | OS | Role |
|------|----|----|------|
| `aios` | 100.78.203.127 | Linux | VPS2 — AIOS, Alyosha, workbench |
| `ilocos` | 100.86.81.127 | Linux | VPS1 — commerce/production (Mayumi) |
| `avi-laptop` | 100.103.92.75 | Windows | laptop — Hermes Desktop, OpenClaw/Hollow |
| `avi-iphone` | 100.64.161.53 | iOS | iPhone — added 2026-08-05; was `iphone172` |

- Owner account: `avipenhollow@gmail.com` (one-person tailnet; default ACL all-reach-all).
- VPS1's OS hostname is still `srv1788663` (MagicDNS node name was renamed to
  `ilocos`; OS hostname unchanged — that's fine).
- A household **iPad** exists but is deliberately NOT on the tailnet yet (Avi
  doesn't use it much); onboard later with the same two-minute flow if/when used.

## Enable Tailscale SSH on a node
```bash
# On the node itself (or via SSH to it):
tailscale set --ssh
```
If SSH'd into the target node OVER the tailnet, it aborts with a lose-ssh risk
warning. Re-run with:
```bash
tailscale set --ssh --accept-risk=lose-ssh
```
Session drops; reconnect via openssh (still on :22). Verify cap present:
```bash
tailscale status --json | python3 -c "import sys,json;d=json.load(sys.stdin);print('ssh' in str(d['Self'].get('Capabilities',[])))"
```

## Rename a node
```bash
tailscale set --hostname=<slug>     # run on the node (or via SSH to it)
```
- MagicDNS name updates to `<slug>`; Tailscale IP unchanged; existing ssh host
  keys/connections by IP unaffected.
- `tailscale status` (plain) reflects the new name immediately; `--json` may lag.
- To rename a node you can't SSH to (e.g. another user's laptop), use the admin
  console: login.tailscale.com/admin → Machines → ⋯ → Rename.

## Connect host-to-host over the tailnet
```bash
# Fresh known_hosts: connect by MagicDNS name, accept-new
ssh -o StrictHostKeyChecking=accept-new root@ilocos '<cmd>'
# or add the IP key explicitly; IP-only connect on a fresh box fails strict
# checking when only the hostname key is recorded.
```

## Taildrop file handoff
```bash
# From any node to another:
printf 'hello' > /tmp/x.txt
tailscale file cp /tmp/x.txt avi-laptop:      # trailing colon = default Taildrop dir
```
Receiver on Windows finds files in `C:\Users\<user>\Downloads\Taildrop\`; a
Tailscale notification may require clicking "accept" on first receipt.

## Hermes Desktop gateway host — stale after migration (diagnostic)
Hermes Desktop's "Gateway Connection" dialog can hold a **stale SSH host** from
before a profile moved boxes. Symptom seen 2026-08-05: the "All profiles"
(default) connection still pointed at **`2.25.71.235` (VPS1)** even though that
profile's agent (Alyosha) lives on **VPS2/`aios`** — so opening the Desktop's
default profile reached the WRONG box (ilocos/commerce, not Alyosha).
Fix: in Gateway Connection → "All profiles" → Connect via SSH → set **Host** to
the correct tailnet name (e.g. `aios` or `100.78.203.127`), keep user/key as-is,
and leave any per-profile overrides (ilocos→VPS1) untouched. This is a one-field
fix — do not chase profile-rename semantics. (Caught/recommended this session;
Avi was mid-application when the session ended, so verify connection after.)

## Onboarding a new device
1. Install the Tailscale app (tailscale.com/download/<os>, or app store).
2. Sign in with `avipenhollow@gmail.com`.
3. Optionally rename the node to a clear slug (admin console or app settings).
4. Verify from an existing node: `tailscale status`.
