# VPS Migration Notes — 2026-08-03

## Machines

| Name | Hostname | IP | Role |
|------|----------|----|------|
| VPS 1 | hermes | 2.25.71.235 | Original machine |
| VPS 2 | aios | 72.61.0.52 | New machine (migration target) |

## Profile Layout on VPS 1 (hermes)

- `/root/.hermes/SOUL.md` — default profile soul
- `/root/.hermes/profiles/alyosha/` — Alyosha named profile (full setup: SOUL.md, config, sessions)
- `/root/.hermes/profiles/ilocos/` — Ilocos named profile

## Profile Layout on VPS 2 (aios)

- `/root/.hermes/SOUL.md` — default profile soul
- `/root/.hermes/profiles/alyosha/` — Alyosha named profile (migrated, full setup)
- No `profiles/default/` directory — default profile uses `~/.hermes/` root directly

## Migration State (as of session 2026-08-04)

- Alyosha profile exists on both VPS 1 and VPS 2 (independent copies)
- Default profile on VPS 2 was running `provider: openrouter` — direct Anthropic API switch was pending
- Telegram pairing was re-approved on 2026-08-03 for VPS 2
- No SOUL.md had been written yet for default profile on VPS 2 at migration time (later confirmed present)
- Group chat "Captain Avi Team AI" is the coordination channel for this multi-agent setup

## Agents

- **Penhollowbot** — runs as default profile on VPS 2 (aios)
- **Alyosha** — runs as `alyosha` profile (VPS 1 or VPS 2 depending on migration state)

## Notes

- SSHing from aios to itself (ssh root@72.61.0.52) will prompt host key verification — run `find` locally instead
- Model string `deepseek-v4-flash-0731` was referenced by user but not yet confirmed as a valid provider slug — verify before applying
