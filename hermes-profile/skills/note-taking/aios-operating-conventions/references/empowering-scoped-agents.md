# Empowering a scoped VPS agent (e.g. Mayumi/ilocos) on VPS1

Mayumi (`ilocos` profile, VPS1) is Avi's **executive assistant for Ilocos
Emporium and Adarna Plant Co.** After the 2026-08-05 upgrade she should be
treated as an operator, not a passive inbox: capture in the moment, identify
gaps, and *propose* skills/tools/access to Avi (propose, don't enable power
unilaterally).

## Where her durable info lives
- **Capture log:** `Efforts/Ilocos-Adarna-Business/Operations/CAPTURE_LOG.md`
  (inside her scoped Docker write mounts). Append-only, newest on top; routine
  business info goes HERE, NOT her memory (her MEMORY.md fills fast). Sensitive
  info (PII/payment/credentials) never goes in the capture log — flagged to Avi.
- **SOUL:** `/root/.hermes/profiles/ilocos/SOUL.md` — now states the live config
  (gateway connected), gives her the capture rule and explicit agency.
- **Charter** (source of truth): `/root/vault/AIOS/Profiles/ilocos - Draft Scope
  Charter.md`. NOTE: the charter was written 2026-07-20 *before* the Telegram
  gateway and toolset expansions — it LAGS the live config. SOUL.md now calls
  this out explicitly ("where they disagree on capability, SOUL reflects what
  is actually enabled"). A charter rewrite was offered but not yet done.

## Her write scopes (Docker rw mounts)
`Atlas/Business/Ilocos-Emporium/`, `Atlas/Business/Adarna-Plant-Co/`,
`Efforts/Ilocos-Adarna-Business/`. Read-only: `AIOS/ME.md`, `AIOS/Vault Map.md`,
and the charter. No path to the rest of the vault by default.

## Workflow to upgrade/extend her (or any scoped agent)
1. **SSH in:** `ssh ilocos` (VPS1). `docker ps` works; her terminal backend is Docker.
2. Inspect current state first: `config.yaml`, `SOUL.md`, `memories/`, `skills/`.
3. **Back up SOUL before rewriting** (many bots this last year revolved around
   subtle SOUL changes): `cp SOUL.md SOUL.md.bak.$(date +%Y%m%d_%H%M%S)`.
4. Build new content locally (e.g. `/tmp/...`, `write_file`), then
   `scp /tmp/file ilocos:/root/.hermes/profiles/ilocos/SOUL.md`.
5. **Changing toolsets requires a gateway restart** — `/new` only resets the
   session context; it does NOT load new config. Restart via systemd:
   `hermes --profile ilocos gateway restart` (sanctioned path). The unit is
   `hermes-gateway-ilocos.service` (system-level, runs `gateway run --replace`).
6. Verify: `systemctl is-active hermes-gateway-ilocos.service`, then read
   `gateway_state.json` — expect `state running`, `telegram connected`.

## How she writes to the vault (the file-tool sandbox trap)
Her built-in **`file` tool does NOT have the vault in scope for writes** — it
resolves a path like `/root/vault/Efforts/...` into her **profile-home sandbox**
(`/root/.hermes/profiles/ilocos/Efforts/...`), and Hermes' sandbox-mirror soft
guard then correctly BLOCKS the write because `/root/.hermes` is her config
area, not the vault. This is not a path bug the user can "fix" — it is the
sandbox guard working as designed.

The write path that actually works for her is her **Docker terminal**, which
carries the real vault rw mounts. Capture instruction in her SOUL must say:
- append via terminal: `echo "- <entry>" >> /root/vault/Efforts/Ilocos-Adarna-Business/Operations/CAPTURE_LOG.md`
- do NOT route through the built-in file tool
- if a given session lacks terminal, she tells Avi rather than force-writing.

### CORRECTION 2026-08-05 — use `code_execution`, NOT terminal
Mayumi's Telegram toolset does **NOT include `terminal`** (as of 2026-08-05 it
is: browser, clarify, file, image_gen, kanban, memory, session_search, tts,
vision, web, skills, code_execution, delegation, cronjob, todo). Telling her to
use a terminal `echo` failed — she has no terminal tool. Her working write path
is the **`code_execution` tool** (shares the Docker backend with the real vault
rw mounts). The capture instruction in her SOUL says:
- append via **code_execution** with a Python snippet and the **absolute** path:
  `with open("/root/vault/Efforts/Ilocos-Adarna-Business/Operations/CAPTURE_LOG.md","a") as f: f.write("- <entry>\n")`
- always use the absolute vault path — never a relative path
- do NOT route through the built-in `file` tool
- if a session lacks both code-execution and terminal, she tells Avi.

**Verify the agent's ACTUAL enabled toolset before prescribing a mechanism.**
Before writing a capability instruction into another agent's SOUL, read its
`config.yaml` `platform_toolsets.<platform>` list and confirm the tool you'll
prescribe is really there. Prescribing `terminal`/`delegation`/`cronjob` without
checking cost a full round-trip this session.

## Vault writes made from the coordinating session DO reach VPS1
A capture log written from the ALYOSHA (VPS2) session propagated to VPS1's copy
via ob-sync — confirmed checksum-identical (`md5sum` matched on both hosts,
same size + mtime). So "the file lives on the wrong machine" is usually NOT the
real problem; on the coordinating side you can create/scaffold the file and rely
on ob-sync to land it on VPS1. Always VERIFY with `md5sum` on both hosts (or
`ob-sync` fully-synced check) before telling the user a placement is done.

## Skills-vs-tools confusion (agent reports "I don't have tool X")
When a scoped agent says it "does not have access to <skill-name> as listed in
my tools," the most common cause is a **skills-vs-tools category error**, not a
real missing capability:
- A **skill** (e.g. `amazon-keyword-research`) is a `SKILL.md` procedure that is
  **loaded** with the `skills` toolset (`skill_view`/`skills_list`), then executed
  with normal tools (browser/web). It is NOT a standalone entry in the tool list.
- A **tool** (browser, file, code_execution, terminal) is what appears in the
  tool list. "My tools don't include amazon-keyword-research" is expected — it's
  a skill, not a tool.
- Fix prompt: tell her to `skill_view(name='...')` to load it, then run the
  research with her browser/web tools. Point to prior evidence she already did
  it (her own 08-03 sock draft contains 240 autocomplete suggestions from this
  skill).
- **Pitfall — don't mistake skills-confusion for the real wall.** When the same
  task keeps failing after the tools-vs-skills fix, re-check *infrastructure*
  before concluding the agent is incompetent (see Amazon bot-gate next).

## Amazon / web-bot-gate infra finding (2026-08-05)
Amazon (and DuckDuckGo, Bing) **block datacenter-IP scraping** from both VPS
agents. Verified live this session: Amazon search → "Sorry! Something went
wrong"/"Dogs of Amazon"; Amazon autocomplete (`completion.amazon.com/...`) →
empty suggestions; DDG → bot-check challenge; Bing → Cloudflare challenge.
This affects **both** Alyosha (VPS2) and Mayumi (VPS1) — it is an infrastructure
limitation, NOT a skills problem, and likely the deeper cause of Mayumi's
repeated "I can't" on the Amazon-keyword task (her sandbox silently fails the
same gate).
Workarounds, cheapest first:
1. **Avi browses from his home IP** (not datacenter-flagged), screenshots/sends
   listing URLs + ASINs; the agent does all analysis/drafting on that data. Zero
   cost, zero infra — the default for single-listing work.
2. Residential-proxy access (Bright Data / Browserbase residential) — recurring
   cost; the "fix infrastructure" path that would also make a scraper
   self-sufficient.
3. Purpose-built tool with its own API (Helium 10, Jungle Scout) — agent drives
   via API; cost.
Knowledge check: keyword/competitor data gathered when a route DID work (e.g. a
vault draft with 240 suggestions) may predate the gate or a now-cut-off route —
don't assume the route still works. Avi's call for now: no spend on research
software for a single listing; deferred to meeting. See vault note
`Efforts/Ilocos-Adarna-Business/Amazon/2026-08-05-Amazon-research-infra-finding.md`.

## Pitfalls (learned the hard way)
- **`hermes config set` mangles list values.** Setting
  `platform_toolsets.telegram` to a comma list stores it as a single quoted
  string `'[browser, ...]'`, not a YAML block list — the schema check then warns
  "not a recognized config key" and the list reads back as one string element.
  Fix: patch `config.yaml` in place, replacing the scalar line with a proper
  block sequence (`- browser`, `- clarify`, ...), then confirm with
  `yaml.safe_load` that the value is a `list` of N elements, not a string.
- **Set `HERMES_HOME` for cross-profile `hermes config set`.** Without
  `HERMES_HOME=/root/.hermes/profiles/<profile>`, `config set` can write to / warn
  about the wrong profile's schema. Prefix the command:
  `export HERMES_HOME=/root/.hermes/profiles/ilocos; hermes config set ...`.
- **Don't kill the gateway from inside the gateway process.** A `pkill` /
  `systemctl restart` issued in a command that runs under the gateway can be
  blocked (SIGTERM propagates to child processes / guard refuses). Use the
  sanctioned `hermes gateway restart` instead.
- **SSH + nohup background restart gets tangled** in session teardown; prefer
  the systemd-managed `hermes gateway restart` so no rogue nohup process lingers.
- **Avi: discuss before running anything on another agent / cross-machine.**
  When he hands over a message from an agent (e.g. Mayumi reporting a block),
  Avi wants a plain-language diagnosis and an agreed fix BEFORE any tool runs on
  the other machine — he said this explicitly ("I don't want you to run anything
  before discussing it with me first"). Explain root cause in plain terms, offer
  a menu, let him choose. Verify-then-claim: he also wanted the fix verified
  (read-back/checksum) before telling the agent it's done.
- **Avi: reproduce the ORIGINAL prompt verbatim when asked.** When he says "give
  me the original prompt / I want it without everything else," he wants the
  exact text as originally given — do not add framing, headers, or commentary,
  and do not embellish/rewrite the brief. Give the raw prompt straight.
