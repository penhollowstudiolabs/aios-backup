# Hollow's OpenClaw remote gateway — phone control when away from the laptop

Goal: keep talking to Hollow from the phone, and be able to restart/manage his
OpenClaw gateway when NOT at the laptop — including from work where the laptop is
on the school district's (campus) wifi.

## Architecture (why Tailscale, not a tunnel)

- Tailscale is an **outbound** tunnel (NAT-traversal + relay). A restrictive
  campus firewall that blocks inbound is irrelevant — the laptop only makes an
  *outbound* connection to the tailnet, which any wifi that loads a page allows.
  So bringing the laptop to work just works; no port-forward, no district-side config.
- Bind the laptop's OpenClaw gateway to the **tailnet**, NOT the public internet.
- Two different gears, don't conflate:
  1. **Talking to Hollow** only needs his gateway running + laptop online (it
     connects *out* to Telegram). No remote setup required for the chat itself.
  2. **Restarting/managing Hollow from the phone when it's down** — THIS is what
     the tailnet-bind provides. And it still can't help a powered-off/asleep laptop.
- Contract: once the bind holds, **aios (Alyosha) can health-check and restart
  Hollow's gateway over the tailnet** on Avi's say-so — that's the real
  "control it without a laptop" lever.

## Tailnet node facts (enrolled Aug 2026)

- Tailnet: `taildc5430.ts.net`
- `avi-laptop` (Windows, hostname DESKTOP-90RGNB6) = Hollow's laptop, 100.103.92.75
- `avi-iphone` (iOS), `aios` (VPS2/Alyosha), `ilocos` (VPS1) — all same tailnet.
- From aios: `tailscale status`, `tailscale ping avi-laptop` confirms the path.

## Recipe (run at the laptop terminal, NOT through Hollow's Telegram session)

```
openclaw config set gateway.bind tailnet
openclaw config set gateway.tailscale.mode serve
openclaw gateway start
```

- Use `serve` (tailnet-only, private, authenticated) — **never `funnel`**
  (publishes to the public internet; do not expose an agent with tool access).
- Do it as a clean one-shot. Then verify BEFORE leaving:
  1. `openclaw config get gateway.bind` → `tailnet`
  2. `openclaw config get gateway.tailscale.mode` → `serve`
  3. `tailscale serve status` → a mapping serving :18789 (may lag the process start
     by 15–30s — re-run if empty before assuming failure)
  4. `tailscale status | findstr avi-laptop` → online
  5. Real test only: **Hollow himself replies in the group** from a fresh
     Telegram session. Nothing else substitutes.
- Serve serves **HTTPS on the tailnet `.ts.net` FQDN** (TLS at Tailscale's side),
  NOT raw HTTP on the IP:port. From aios: `curl -sk https://avi-laptop.taildc5430.ts.net/health`.
  An empty response on the IP:port is expected; empty on the FQDN usually = still
  provisioning or serve not applied.

## OpenClaw gateway health check (any box)

- Default OpenClaw gateway port: **18789** (`gateway --port 18789`).
- Health endpoint: `curl -s http://localhost:18789/health` → `{"ok":true,"status":"live"}`
  (`/` and `/metrics` also return 200).
- Process/listener: `ss -tlnp | grep 18789`, `ps aux | grep openclaw`.
- CLI: `openclaw gateway --help` (flags: `--bind tailnet|loopback|lan|tailnet`,
  `--tailscale serve|funnel|off`, `--port`, `gateway start|stop`).

## PITFALL — reconfiguring the gateway cuts the Telegram bridge you're watching

You cannot change `gateway.bind` / `tailscale.mode` on the SAME gateway instance
that is carrying the live Telegram session — the associated stop/restart kills
the exact process that talks to Telegram. That is why Hollow repeatedly "goes
quiet" mid remote-setup: the tool being reconfigured IS the channel being watched.
This is not a crash. Do the setup from the laptop's own terminal in one clean
shot, then verify in a fresh session.

## PITFALL — "Redirected current run (iteration 1/500)" ≠ evidence Hollow is alive

OpenClaw/my gateway can post internal status notes into the chat like
"Redirected current run (iteration 1/500). I'll adjust using your correction."
This is the agent's OWN gateway acknowledging a mid-run user input (step counter =
N of a per-run budget, benign). Do NOT read such a post as proof another agent
(Hollow) is up. The only valid Hollow heartbeat is Hollow himself replying in the
group. This session I misattributed my own status post to Hollow.

## Recovery quick-triage (from aios) + the "bump Hollow" lever

When Hollow is "gone": triage in order, don't restart blind.
- Laptop up? `tailscale ping -c1 --timeout=4s avi-laptop` → `pong` = machine+tailnet OK.
- Gateway serving? `curl -sk https://avi-laptop.taildc5430.ts.net/health` → `live`.
  - **Ping OK + health empty → gateway process is DOWN → needs a restart.** Not network, not quota.
  - **Health live but Hollow ignores/slow → bloated session context / model latency → `/compact` or a fresh session, NOT a restart** (a restart won't fix it).
- Restart at laptop (Admin PS):
  ```
  openclaw gateway stop
  openclaw gateway start
  ```
  Watch 20–30 s. Startup config-parse/bind errors = a half-applied config from an interrupted write → paste the first error, fix the one line, don't re-guess.
- **`exit 124` on a command = timed out / killed, NOT success.** A hung `config set` may have partially applied — re-read with `openclaw config get ...` before assuming state (timed-out `tailscale serve ...` during setup is often just serve being account-gated, below).
- **The "bump Hollow" lever:** once the bind holds, Avi says "bump Hollow" and Alyosha restarts the gateway from aios over the tailnet — no laptop needed. (Still needs the laptop awake + online; powerless if the machine is off/asleep.)

## Model rotation on the laptop — fixing a stalled/hung Hollow (8/7)

Hollow's most common "went quiet at the laptop" cause (after gateway restart) is a
**model/auth-order problem**, not a crash. Signature from the log: he runs
`openclaw config validate`, edits a `*model-rotation-plan.md`, then `openclaw gateway restart`
and goes silent. If Codex is first/primary and its plan quota is **capped**, the
rotation stalls at the top of the chain.

**Fix — set Sonnet primary, Anthropic auth first, restart** (run in Admin PowerShell
at the laptop; treat the post-restart silence as the expected tail, not a rescue):
```powershell
openclaw models set anthropic/claude-sonnet-4-6
openclaw models auth order set anthropic
openclaw gateway restart
```
Verify by Hollow himself replying and confirming he's actually ON sonnet — a
401-fallback (dead `claude-cli` OAuth / no usable `ANTHROPIC_API_KEY`) can make him
talk while silently running a different model; that exact failure hit on 8/05.
If `anthropic/claude-sonnet-4-6` isn't the identifier his install accepts, `openclaw models list`
shows the real string — but reach for this only if the set fails, don't pre-emptively scrape docs.

### PITFALL — when Avi asks for the fix, give the commands and stop ("just the commands", 8/7)
When Avi is at the machine and asks "just tell me what to do / give me the commands",
hand him the verbatim terminal commands and stop. Do NOT: scrape docs to "verify"
syntax first (his `--help` is authoritative and available), present options A/B/C and
ask which he prefers, or relay him back more questions. He corrected twice on this
in one session ("you are doing too much. Just the commands"). If a command might
fail on his exact install, note the fallback in ONE line and move on — don't build
a decision tree.

## When Avi panics ("I regret fucking with everything / it was fine before")

Ground him in facts, don't over-justify: (1) the instability predated today —
the same "goes quiet" happened on earlier days mid model-switch, before any
of today's changes; (2) every change made is an *addition*, reversible, nothing
deleted/data lost; (3) the new remote-restart capability *removes* the
"must be at the laptop to fix Hollow" lockout. De-escalate.

## District-wifi / AUP honesty frame

- A VPN/tunnel is not automatically a policy violation, but two distinct clauses
  can bite: (a) **circumvention** — tunneling *around* a district block that
  denies/distrusts VPNs; (b) a flat "no VPN/tunnel software" AUP. "Most AUPs are
  fine" is not "yours is." Avi is the credentialed employee there; the definitive
  check is his own AUP (grep `VPN|tunneling|circumvent|personal devices`) + IT.
- Clean sidestep: run the agent traffic over the **phone's cellular hotspot**
  instead of district wifi — no district network involved, nothing to circumvent.
  Keep district wifi for ordinary browsing.
