# Hermes Desktop refresh — clean update, two halves (verified 8/21)

Context: Avi's Hermes Desktop "never worked" after moving things around; he wanted a
fresh update including Bot Mode on both the backends it connects to and the app UI.
The durable lesson: **the desktop app and the server backends it connects to update
on SEPARATE clocks.** Fixing one half and calling it done is how the desktop stays
"fucked up" with the feature present in the UI but dead on the wire.

## The two halves (both required for Bot Mode to actually work)

1. **Backend side (aios/VPS2 — the `hermes serve --isolated` processes + gateway).**
   `hermes update` brings the agent code forward. This is the side I CAN touch.
2. **Desktop app (avi-laptop — the Electron UI itself).** I have NO SSH into the
   laptop; this half needs `avi-laptop` running **Settings → Advanced → Update
   desktop app** (one-click; the app self-detects a stale backend and offers it),
   then **Settings → Connections** pointed at the `alyosha` backend over the tailnet
   (host `aios`), not the generic default profile. Bot Mode then renders from the
   fresh app against the fresh backend. Hollow/Avi run this step, not Alyosha.

## Server-side update recipe (what actually worked)

1. **Prove the drift before acting.** `hermes --version` shows the tag; compare to
   latest release tag via `git ls-remote origin refs/tags/*` in the install root
   (`/usr/local/lib/hermes-agent`). This session: v0.20.0 / v2026.8.3-40-g9c88625
   vs upstream v2026.8.18, **3725 commits behind** (`git rev-list --count HEAD..origin/main`).
2. **Full backup for a big jump.** `hermes update --backup` saves a zip to
   `~/.hermes/backups/pre-update-<ts>.zip` (108 MB here), recoverable via
   `hermes import <file>`. Large jumps warrant the full backup over the default
   `quick` state snapshot.
3. **Fetch may 429.** GitHub rate-limits (`RPC failed; HTTP 429`) — transient.
   Retry with a plain `git fetch origin main --tags` (background) before rerunning
   `hermes update --yes`. Confirm clean tree (`git status --porcelain | wc -l` = 0)
   so the update's auto-stash has nothing to fight.
4. **Run `hermes update --yes` in the BACKGROUND** — it restarts the gateway and
   can drop the bot ~5–15s; background so it survives the restart it triggers.
5. **Post-update:**
   - `hermes --version` → confirm bumped (v0.20.4 / upstream 40643cba) and `Up to date`.
   - `hermes doctor` → then `hermes doctor --fix` (clears config migration + the
     `~/.local/bin/hermes` symlink).
   - Remaining npm advisories: see pitfall below.

## PITFALL — `hermes update` only refreshes the DEFAULT (non-profile) serve backend

`hermes update` stops/restarts the dashboard/serve process it owns — but a
**profile-pinned serve** (`hermes --profile alyosha serve --isolated ...`) started
standalone is a different process and does NOT get refreshed. It keeps running the
old code in memory. Verified: after update, a stale `--profile alyosha` serve from
Aug 4 was still alive while the generic one had been restarted.

Removing a stale profile serve: **don't try to respawn it server-side.** That serve
was spawned by the Desktop app on the laptop over the Tailscale SSH tunnel with a
**session-scoped token** (`--ssh-session-token-file .../desktop-ssh/<id>/*.token`).
The moment the process dies, the token is consumed/removed — respawning with the
same token arg fails with `--ssh-session-token-file is not accessible`. This is
NORMAL, not breakage: the desktop app (re)spawns a fresh serve backend on next
connect. Zero live `serve` processes + healthy gateway = expected idle state.

Corollary for the "desktop points at the wrong backend" confusion: stale
`backend.lock.json` pids mean nothing; check live processes (`ps -eo pid,args |
grep "serve --isolated"`) and `systemctl is-active hermes-gateway` for truth.

## PITFALL — npm audit fix on the Hermes monorepo (build-tree advisories)

`hermes doctor` reports `web workspace has N npm vulnerabilities` / `ui-tui ... .`
These are **build-time tooling, not runtime** code that ships to users. The legit
fix is a **lockfile bump** (`npm ci --include=dev`), which is frequently blocked:

- Plain `npm audit fix` aborts on a Conflicting peer dependency (`vite@8.2.2` vs
  `@rolldown/plugin-babel` wants vite `^8.0.0`).
- `--force` crashes on npm's own arborist bug: `Cannot read properties of null
  (reading 'edgesOut')`. Doctor's code explicitly calls this a KNOWN npm bug and
  deliberately refuses to hand out a `--force` remediation, because forcing
  electron would install `electron@40.10.6` **outside its declared supported
  range** — a genuinely risky, possibly broken upgrade.
- Findings live in `apps/desktop/node_modules` — a DIFFERENT workspace tree than
  the root lockfile (`npm ci` at root: "Missing: <pkg> from lock file").
- `--legacy-peer-deps` and `--workspaces=false` both complete but resolve zero.

Correct handling: these advisories clear naturally when the desktop app on the
LAPTOP rebuilds its deps (the same "Update desktop app" step Bot Mode needs). Do
NOT force `npm audit fix --force` on the server to chase a `doctor` green. Leave
the server backends healthy, state the two advisories are desktop-build-owned, and
home the pending item on the laptop step.

## Do not capture as a rule
Do not read these as permanent blockers: they're a transient state (fresh large
update on a monorepo with a known npm arborist bug) that will age out when the next
desktop build regenerates the tree. The durable, portable workflow is the
two-halves + backup + doctor recipe above.