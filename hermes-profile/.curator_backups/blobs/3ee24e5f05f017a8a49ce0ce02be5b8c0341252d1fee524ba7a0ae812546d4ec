# Hermes profile inventory & the "default profile" architecture

Verified 8/21 while inventorying both VPSes for Avi. Use when surveying Hermes
profiles across the AIOS, diagnosing why a generic "default" profile shows up,
or helping with Hermes Desktop attachment.

## The two "defaults" (resolve the confusion first)

1. **Sticky default** — decided by an `active_profile` file at the install home
   (`~/.hermes/active_profile`). When it's absent, bare `hermes` opens the
   generic install profile. Set it with `hermes profile use <name>`. This is
   the one that decides what launches by default.
2. **The `default` profile directory** (`~/.hermes/` itself) — the reserved
   install/bootstrap home. Hermes **refuses to delete it** ("Cannot delete the
   default profile (~/.hermes)"). You may promote another profile to act as
   default, but the `default` directory physically cannot be removed. Its
   presence is normal, not a bug.

A leftover `default` is usually **residue of a half-migrated setup**, not Nous
architecture: when the working agent (Alyosha/Mayumi) was promoted on one VPS
but not the other, the old install default went inert (gateway stopped,
telegram disconnected) but kept its name.

## Inventory recipe

Local (aios, VPS2):
```
hermes profile list                 # marks active with ◆, shows model+gateway+alias
hermes profile show <name>          # path, skills count, .env, SOUL, alias
grep -A3 "^model:" <home>/config.yaml   # primary model/provider
cat <home>/gateway_state.json       # running/stopped, per-platform connection state
```

Remote (ilocos, VPS1) — tailnet-only, BatchMode, never print key values:
```bash
ssh -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new ilocos '...'
# same checks +: cat /root/.hermes/active_profile    # shows sticky default name
```

## Desktop wiring (independent of gateway)

The desktop app connects over a **Tailscale SSH remote-gateway tunnel** to a
`hermes serve --isolated` endpoint. A serve process can be healthy while NO
desktop tunnel points at it (and vice versa), so "desktop broken" is usually
really "desktop pointed at the wrong profile."

Identify the live attachment:
```bash
ps -eo pid,args | grep "serve --isolated"   # each serve endpoint + its profile
ss -tlnp | grep -E "127.0.0.1"              # listening serve ports
ss -tnp | grep <serveport>                  # established client = who the live tunnel touches
```
`backend.lock.json` under `~/.hermes/desktop-ssh/<id>/` records the ownership,
profile, port, token fingerprint, and protocol version of each served backend.

## Version reconciliation — prove what's ACTUALLY running (8/21)

A VPS backend can look healthy while being many commits stale, and the stale
backend is often the real root of "desktop doesn't work / feature X isn't
here." Do not claim version drift from memory — prove it with git:

```bash
cd /usr/local/lib/hermes-agent
git describe --tags --always        # e.g. v2026.8.3-40-g9c88625e25  = tag + commits past
git log -1 --format='%h %ci %s'     # local HEAD + its commit date
timeout 30 git ls-remote --tags origin 2>/dev/null | sed 's|.*refs/tags/||' | grep -v '\^{}' | sort -V | tail -10   # upstream release tags
git ls-remote origin refs/tags/*    # pull the live tag list
```

- Local `git describe` `v2026.8.3-40-g<sha>` means: checked out 40 commits
  past the v2026.8.3 tag — **not** the same as being on v2026.8.3.
- The `behind` NNNN count in `<home>/.update_check` (and per-profile
  `.update_check`) quantifies drift from upstream.
- To see WHAT a newer release actually added, diff the range:
  `git log --oneline v2026.8.3..v2026.8.18` — this is how you verify a claimed
  feature (e.g. "bot mode") is real and which side (app vs backend) carries it.

**The version-drift insight (8/21):** a feature can ship in the **desktop app
build** the laptop runs while the **server backends** it connects to are stale
`hermes serve` processes. That mismatch (new UI on top of an old backend) is a
common, invisible cause of "the desktop is fucked up" — the app renders a
pane/mode the connected backend simply doesn't implement. Before diagnosing
desktop wiring, check both sides' versions; the fix may be `hermes update` on
the server, not another round of tunnel surgery.

## Live-updating the aios backend — the desktop↔serve trap (8/21)

`hermes update --backup --yes` on aios refreshed the install cleanly, but the
desktop↔serve wiring left two durable gotchas worth carrying:

1. **`hermes update` only refreshes SOME serve backends.** It mapped and
   restarted the generic-default `serve --isolated` process, but a
   **profile-pinned** one (`--profile alyosha serve --isolated ...`) that a
   previous desktop session had spawned kept running on the OLD code in
   memory. If the desktop attaches to that profile, Bot Mode / newer protocol
   still 404s. Catch it by comparing `ps -eo pid,lstart,args` before vs after
   the update — any `serve` with an old start-time is stale.

2. **You cannot respawn a serve backend from the server side.** These backends
   are spawned BY the desktop app (client) over the Tailscale SSH tunnel, with
   a **session-scoped `--ssh-session-token-file`**. Kill the process (or the
   client session drops) and that token is consumed/removed; a manual respawn
   dies instantly with `--ssh-session-token-file is not accessible`. This is
   NOT breakage — the desktop respawns fresh serve backends on its next
   connect. So "no serve running on the server" between desktop sessions is
   normal, and a stale server-side serve that won't respawn is fixed by
   closing/reopening (or re-pointing) the desktop app's connection, not by
   terminal surgery on the server.

Also: GitHub `git fetch` can 429 mid-update (rate limit) — the backup still
lands, so just retry. And `npm audit fix` on the just-rebuilt `web` / `ui-tui`
workspaces correctly refuses on an upstream vite peer-dependency conflict —
leave it rather than `--force` a possibly-broken graph. Post-update validation
per the docs: `git status --short`, `hermes doctor`, `hermes --version`,
`hermes gateway status`.

## Decommission / migration frame — data first, platform after (8/21)

When Avi is past "fixing" and says he's planning a migration OFF the platform:

- **Extract the durable, portable layer first, not the wiring.** The parts
  that are actually *his* accumulate in plain files: the vault (`/root/vault`),
  memories, skills. Those move to any next platform. The rest (desktop tunnels,
  serve endpoints, gateway config, cron) is scaffolding to be torched clean.
- Reframe the exit as "one task from migration-safe" — start the portable
  export (plain text, no platform dependency) and *then* decide salvage vs
  decommission from calm ground. Export is insurance for both paths.
- Don't keep treating a report of breakage as a **fix signal** when the user
  has gone strategic. Re-read the preference note: past a certain point the
  ask is honest status, not another repair promise.

`hermes profile use alyosha` (or `ilocos`) → sets the sticky default so bare
`hermes` and desktop upstream open the working agent. Reversible with
`hermes profile use default`. Do NOT attempt to delete the `default` directory
— Hermes refuses, and it's the reserved bootstrap home.

## Style (Avi 8/21)

When Avi pushes back on tooling he doesn't like ("why would they set it up this
way?"), separate platform design from residue of his own setup and name which
one it is before proposing a fix. Validate the premise first ("you're right,
it's unnecessary weight"), then name the real cause (a leftover, not
intentional). Don't defend a design decision that isn't actually one.

**When Avi says we've done this before / stop promising the fix (8/21):**
he is explicitly out of patience for "promise a fix → spend hours repairing →
repeat." The first response is NOT a new repair plan. Lead with *verified
claims only*: prove the version drift with git, confirm the feature actually
exists in both code and doc, and state plainly what is and isn't functioning.
If he signals decommission/migration, orient to the portable-data extraction
(above), not to another wiring fix. Avi has said he wants: honest status,
historically accurate reconciliation, and a real plan toward where he wants to
go — not another "give it one more rebuild."