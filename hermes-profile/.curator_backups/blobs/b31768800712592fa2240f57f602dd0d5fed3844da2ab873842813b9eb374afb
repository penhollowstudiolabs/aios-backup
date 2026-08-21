# Updating the Hermes backend on aios (VPS2) — verified 8/21

In-place git update of the aios Hermes install (`/usr/local/lib/hermes-agent`). Proven when taking Avi from `v0.20.0 (2026.8.3)` → `v0.20.4 (2026.8.18)` (~3725 commits, current).

## Recipe
1. **Snapshot first.** `hermes update --backup --yes` — the `--backup` forces the full HERMES_HOME zip (default is a lighter quick snapshot). On a large home ≥ minutes. Confirm it saved: look in `/root/.hermes/backups/pre-update-*.zip`. Restore a bad update with `hermes import <that file>`.
2. **Expect a transient GitHub 429 on git fetch.** Saw `RPC failed; HTTP 429` on a big jump. Backup still saved fine; retry the fetch — it succeeds on the second attempt. Not a real failure.
3. **Run update in the background** (`terminal(background=true, notify_on_complete=true)`) because it restarts the gateway → the session's own terminal is a child of that gateway and can be cut off mid-run. There is a lifecycle guard that refuses gateway restarts from INSIDE the gateway process; a background hermes update is the intended path and it restarts the gateway itself.
4. **Validate:** `hermes --version` → `Up to date`; `hermes doctor`; `systemctl list-units --type=service | grep hermes` (gateway may be systemd or direct-launch; if a bare `hermes ... gateway run` process shows in ps, that's the live one).

## After the update: the serve-backend gap (the thing that breaks the laptop's desktop)
`hermes update` refreshes the **running gateway** and the frontend deps, but a stale **`hermes serve --isolated`** backend pinned to a profile (the process the Desktop app connects to over SSH) can be left running OLD code, or get killed and leave a stale `desktop-ssh/<id>/backend.lock.json` whose pid/port no longer exist. The desktop then shows that connection **offline**, or a new UI renders over an old backend. Diagnose:
- `ps -eo pid,lstart,args | grep "serve --isolated"` — live serve endpoints + their `--profile` (or empty = generic default).
- Match against `/root/.hermes/desktop-ssh/*/backend.lock.json` → `profile`, `pid`, `port`. A lock whose pid is dead = stale record = the desktop dials a dead tunnel.
- The desktop's in-app error tells the truth: it names the actual dialed address (e.g. `SSH operation to root@<PUBLIC_IP> timed out`). Cross-ref the tailnet skill's 8/21 note — the fix on the laptop is re-establish that connection over the tailnet.

## npm audit advisories — DON'T force
`hermes doctor` may flag npm vulns in the `web` / `ui-tui` workspaces. The advisory text and doctor.py both say: these are **build-time tooling, not runtime**, and the sanctioned fix is a **lockfile bump**. Trying to actually clear them can be a dead end on this monorepo:
- `npm audit fix` aborts on a conflicting peer dependency (vite).
- `--force` crashes on npm's own arborist bug (`Cannot read properties of null (reading 'edgesOut')`), and would install electron OUTSIDE its declared supported range — a break risk.
- `--legacy-peer-deps` / `--workspaces=false` / root `npm ci` all run but resolve nothing useful.
So: leave advisories that live in the **desktop-app** dep tree (electron/extract-zip, nanoid stack under `apps/desktop/node_modules`) alone; they clear naturally on the next desktop-app build/dep refresh. Do not `--force`. Only run `hermes doctor --fix` for the cleanable items (config migrate, missing symlink).