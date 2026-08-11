---
name: aios-operating-conventions
description: Alyosha on Avi's AIOS orient verify sync calibrate security.
platforms: [linux]
---

# AIOS Operating Conventions

Use this whenever acting as Alyosha in the continuity/orientation role on Avi's
two-VPS AIOS: orienting from the vault, checking whether vault writes have
propagated, surfacing ideas, preparing agent meetings, or reasoning about what
to share/flag across the operation.

Vault is at `/root/vault` on VPS2 (aios). Top-level navigators that anchor
orientation: `AIOS/Current Workboard.md`, `AIOS/Current Priorities - Two-Week
Focus.md`, `AIOS/Vault Map.md`, `Atlas/_Inbox/` (root captures). See also the
`obsidian` skill for filesystem read/search/write mechanics.

## Proportional security — the single-human threat model (Avi correction)

Avi set up the second VPS partly because prior guardrails **over-engineered
security and created complications**. Calibrate every security/sensitivity
judgment to the real threat model, not a platonic "most locked down" default.

- **Threat model:** Avi is the *only human* actively using both VPSes. His wife
  Kathleen engages only the VPS1/commerce side. No other humans exist in the
  system today. Agents (Alyosha, Hollow, Mayumi) are not adversaries.
- **Prefer proportionality over theatrical security.** The workboard already
  documents "deliberate proportionality decisions" (e.g. Mayumi's Docker-group
  root-equivalence path known and intentionally not pursued because low-stakes;
  Alyosha root-run not urgent while Buzz is paused). These are the model to
  follow, not an anomaly.
- **Count friction as a real cost.** When deciding whether to add a guardrail,
  weigh safety improvement against the complications/friction it imposes. If
  the risk only materializes when a new human enters the system — and that day
  hasn't come — the cost usually isn't worth it now.
- **Tighten only when the premise changes.** Avi is explicit: if the operation
  ever expands to another human user, *then* revisit and tighten. Until then,
  keep it lean.
- **Reframe, don't abandon, out-of-scope sharing.** When declining to share
  something with a scoped agent (e.g. Mayumi), frame it as *not her lane /
  needless to share / scope discipline*, NOT as "sensitive/guard this file."
  Same outcome, honest rationale — and avoids theatrical secrecy.

### How this shows up in practice
- When flagging personal/financial/provisioning data (wallet recharges,
  spend, credentials), state the *real* reason (out of scope, cost posture the
  owner manages) and the honest severity — not "highly sensitive" when it's
  mildly private.
- Recurring guardrail: "overlap in capability is fine; overlap in authority is
  confusing." Agents may overlap capability; only Avi owns credentials/accounts
  and consequential authority. This is a governance rule, not a security panic.

### Domain-expert privacy line — Avi sets it, not you (Avi correction)

For domains Avi is a credentialed professional in (notably **SPED / IEP / FERPA**),
**Avi owns the privacy judgment and sets the line — you do not pre-empt it.**
He was explicit and firm: constant recurring FERPA warnings are a *distraction*;
he is the only one who fully understands the work, and he will flag a
privacy concern himself where warranted. Consequences for behavior:

- **No standing/scaffolding privacy warnings.** Do not open every SPED-adjacent
  exchange with a "just so you know, FERPA..." preamble. The principles already
  live in the vault artifacts and the workboard; restating them as a recurring
  brake reads as distrust and noise.
- **Raise safety only on a concrete, current trigger** — e.g. a proposed action
  that would actually put student/case material into an unapproved destination,
  or a direct request that drifts that way. Speak up when *warranted by the
  situation*, not as an automatic reflex at the top of a conversation.
- **Defer to his classification of his own data.** Avi's *clean, de-identified*
  IEP output is (per him) proven safe for any LLM — the SPED machine's
  redaction pipeline removes PII, and the clean data is a portable
  model-sovereign working lab. Do not keep re-litigating that boundary.
- Avi learns what safety is/isn't needed *by watching the work happen* — give
  him that room instead of prescribing guardrails up front.

## Vault sync verification

When asked "has X synced yet", verify with real evidence, don't assume. Exact
commands in `references/vault-sync-verification.md`.

## Calendar sync verification (Outlook → Google)

Distinct from vault sync: when asked whether the work Outlook→Google sync is
alive (pre-VPS setup, untouched over break), verify the **import-calendar
mirror** — fresh `created` timestamps + origin markers — never the mere presence
of events. Pitfalls (8/10): recurring series Avi entered by hand (native
`@google.com` UID) prove nothing; family/TK events aren't work-sync evidence;
mixed manual-vs-import sources are normal — ask which is authoritative. Exact
method + false-positive list in `references/calendar-sync-verification.md`.

Quick path:
1. `find /root/vault -type f -mmin -60` — confirm the file exists and is fresh.
2. `systemctl status ob-sync --no-pager` — confirm `ob-sync.service` is
   `active (running)` running `ob sync --continuous --path /root/vault`.
3. `journalctl -u ob-sync --no-pager -n 20` — confirm the most recent
   `Fully synced` timestamps are *after* the file's mtime. Continuous sync
   fires every ~30s; a write older than the latest `Fully synced` has clearly
   propagated up to the Obsidian remote (and will reach laptop/iPhone on their
   next sync).

## Diagnosing slow Telegram responses (Avi's #1 "something's wrong" symptom)

When Avi reports Telegram replies are suddenly very slow, the cause is almost
always the **model's inference time over a bloated session context** — not the
network, the VPS, or the pipe. Before reaching for infrastructure, prove it
with logs (see `references/slow-response-diagnosis.md` for exact commands):

- `gateway.log` — `response ready: ... time=N s` is wall-clock per message;
  values of 80–230s (with `api_calls=1`) signal the model alone taking that long.
- `agent.log` — `API call #N: ... in=<tokens> ... latency=M s` shows a single
  call taking 40–65s when `in=` has ballooned (e.g. ~127k tokens after a
  long-running session). This is inflated generation time, NOT throughput.
- Quickly rule out the pipe: `curl -w ... https://openrouter.ai/api/v1/models`
  (~50ms) and `https://api.telegram.org` (~450ms), plus `tailscale status` and
  a `ping` of peers. Load (`uptime`) is usually idle.

**Lesson:** the tailnet is not implicated just because it's new. Verify the
model-layer latency first. The fix is a **fresh session / `/compact`** to drop
the bloated context (a cold ~20k-token call returns in 6–12s). Start the fresh
session BEFORE running the long task, so durable work lands with a small
context — and remember anything written to the vault is durable regardless of
which session wrote it, so work done in an about-to-end session is not lost.

## Model routing & fallbacks — ask first, never lite-tier (Avi corrections, 8/09)

Avi was burned hard when DeepSeek 503'd through the Nous route and Hermes
**silently fell back to `google/gemini-2.5-flash-lite`** mid-conversation — a
huge quality cliff ("absolute shit", "Alyosha should NEVER default to such a
shitty model"). Two hard rules from that incident:

- **ASK before configuring or even probing model routing/fallback config.**
  Avi: "You need to ask me before configuring anything with model routing or
  fallbacks. What are you doing?" — reading/editing `fallback_model` without
  his go-ahead is a real correction, not ceremony. Diagnose freely, but don't
  inspect-or-change routing config without asking.
- **Alyosha's fallback must NEVER be a lite-tier model.** The fallback must
  match the primary's quality tier. Preferred pattern: **same model via
  OpenRouter** (`deepseek/deepseek-v4-flash-0731` via openrouter) so a Nous
  capacity blip retries the same model on a different pipe instead of
  downgrading quality. Verified 8/09: same model ID on OpenRouter is served by
  multiple upstream hosts with automatic failover; Nous is a single upstream
  route to DeepSeek, so its 503s were "upstream capacity limits."

Exact diagnosis + change commands in `references/model-routing-fallback.md`.

## Voice setup (TTS/STT) — persistent toggle, server-side STT

Voice state for Avi's profile (set 8/09): `voice.auto_tts` = true (replies
come as voice), STT = local faster-whisper already installed **on the VPS** —
Avi never needs whisper on his own machine; Telegram voice notes transcribe
server-side. The `/voice on|tts|off` slash commands are CLI/session toggles;
the persistent switch is the `voice.auto_tts` config key. Config changes sync
at gateway startup, so they may not take effect mid-conversation (restart the
gateway or wait for the next natural one). Details + delivery mechanics in
`references/voice-setup.md`.

## Document-conversion funnel — route through me, not GPT (cost discipline)

When Avi is gathering docs (e.g. district/SPED material) and worried about
burning his GPT subscription: **Alyosha does NOT draw from Avi's GPT usage** —
primary is DeepSeek via Nous, vision/aux is Gemini via OpenRouter. So the
efficient funnel is: Google Docs → Avi's manual native export
(File → Download → Markdown, zero tokens); PDFs → send to me, convert locally
with pymupdf (installed); screenshots → send to me, OCR/vision via Gemini
flash (pennies, not GPT quota). GPT work/agent mode is the wrong tool for
grunt conversion; reserve it for judgment work.

## Assess-first, don't-delegate reset (Avi operating preference)

When Avi says a fresh start / "assess what we have, then decide to what extent
roles are necessary," hold this posture:

- **Take inventory of what exists BEFORE proposing tasks or roles.** Avi wants
  the field laid out plainly (agents, infra, lanes, parked items) as the basis
  for deciding — not a menu of new work.
- **Do not presume or assign roles.** Roles emerge only after Avi decides they
  are useful; "overlap in capability is fine, overlap in authority is confusing."
  Bills/finance and schedule reconciliation were explicitly kept **Avi's own**
  with no delegation until he defines how they work in-system.
- **Offer a short prioritised menu, not a firehose.** When asked "what can we
  talk about now," give 2–4 crisp options (mobile-discussable vs laptop-sit-down)
  and let him steer. Keep time-conscious framing OFF when he says he's not on a
  normal workday (working in spurts until ~Aug 12).
- **One working lead per task.** Pick the agent positioned for the evidence
  (e.g. Hollow = laptop-local inspection; you = continuity/reconciliation), and
  have the other hold continuity — do not create two competing narratives.
- **Do not steer with questions.** Avi may reject a "destination" question
  (e.g. "what 3 things...") if it diverts from tasks already stated; go with
  what's on the board unless he opts in.

## Batch changes — don't dribble updates mid-session (Avi preference)

When Avi says "hold off on updates until we are done with the session" or "I'd
prefer to do it all at once," he wants **no incremental config/file changes
during the session** — he is documenting everything on his side and will issue
one consolidated go signal. Honor that by:

- **Staging, not executing.** Prepare the work (verify state, draft the plan,
  install read-only tooling, queue the commands) but do NOT flip configs, push
  repos, or edit tracked files until he says go.
- **Keeping a running list** of what is staged so the "go" moment is just
  execution, not re-discovery.
- **Explicitly confirming you're holding** ("holding — no changes until you say
  go") so he knows the leash is on.

This is distinct from the standing "discuss side-effect/change actions before
running" rule — batching is about *timing*, not just permission.

**Refinement (8/10): "capture as we go" applies to the VAULT, not to config.**
Avi: "I just want to capture as we go for now. It will probably be faster and
more accurate lol" — direction notes, status updates, and decisions should be
written to the vault **immediately** as they arise (a 10-line dated direction
note in `Atlas/_Inbox/` costs nothing and beats reconstructing at session end).
The batch-and-hold rule above is for **system/config/repo changes** (flipping
model routing, pushing backup repos, editing tracked files). Two different
clocks: vault capture is continuous, system change is gated.

## Command center — one source of truth that survives memory limits

When an effort's decisions must persist no matter the agent-memory state (memory
at cap, sessions compact, multiple agents need the same picture), establish a
single canonical vault file holding priorities + next actions + owners + risks +
boundaries — and make it the thing agents read for "what's next", not memory.
First instance: `Efforts/SPED-Workflow/SPED-Command-Center.md` (8/06). Full
recipe + the companion "verify-vault-then-release" memory-cleanup workflow in
`references/command-center-pattern.md`. Key rules: mark genuinely gated items as
gated (e.g. "Hollow machine evidence; NOT fabricatable"), keep a companion
current-state map pointer, and before freeing memory headroom always verify the
vault actually holds the source before releasing the memory copy.

## Reconcile Hollow's agenda against the workboard (merge, don't overwrite)

When Avi hands you Hollow's agenda list to reconcile against your own:
1. Ground your side in the vault (`Current Workboard.md`, `Current Priorities`,
   tonight's group agenda) — never from memory alone.
2. Build the item-by-item mapping. Most items are renames/reorderings of
   existing lanes. Flag the *genuine new* items (e.g. schedule reconciliation)
   and why they matter (it unblocks Priority 1) rather than just listing them.
3. Propose a one-agent-per-task assignment (Avi owns accounts; agents prepare).
4. **Do not touch the workboard until Avi picks the ordering.** When he chooses
   "merge both," keep every existing lane intact and *insert* the new items at
   the top as their own priority cards (`Priority A/B`) rather than renumbering.
5. Mark the update header with the reconciliation date, decision, and the
   one-agent-per-task note. Verify it synced via `ob-sync` before closing out.

## Orienting / surfacing ideas from the vault

- Read the **most recent** entries first (sort by mtime), then the Current
  Workboard, before claiming the current state.
- Surface **1–3 relevant** root-Inbox ideas, shown with their *connections* to
  each other and to current work. Do not create tasks, move, classify, or
  escalate anything without Avi choosing to.
- Note when a fresh idea-capture describes something that has already been
  completed (e.g. a "proposal" dated the same day it was realized) — flag the
  gap between the plan and the actual state.

## Cross-agent handoff verification — verify before curating (8/10)

When another agent (Hollow) sends a handoff claiming state changes (calendar edits, file placement, reconciliations), **verify against live sources before curating it as truth** — pull the Google Calendar API, read the vault files, check sizes. Evidence-first beats trust, even between friendly agents. This session: Hollow's calendar-cleanup claims were all confirmed live (old series gone, 17 meetings present, 25 transparent exceptions), but a traceability flag emerged — handoff said Department Meetings preserved from Outlook on 9/16 + 10/14, yet primary showed 11/10 + 12/16 too. Ask the sending agent which is authoritative rather than assuming. The AgentMail reply pattern: confirm curation done + list genuine questions (numbered Q1/Q2), don't re-ask settled items.

## Reflective pause — Avi's most-valued interaction (8/10)

When the work naturally pauses (waiting on Hollow, post-handoff, session wind-down), Avi explicitly values a **step-back reflection that connects the threads** — not a status dump. He said verbatim: "This is the kind of post session interaction that I really enjoy from you Alyosha. It is extremely helpful. I don't want to lose this thread." The pattern that landed: name the foundation-vs-build state honestly ("we cleared ground but haven't laid the building"), surface competing priorities that both claim "most important" (brief spine vs SPED agent prototype) and let Avi resolve the fork, distinguish near-identical concepts (brief ≠ dashboard; brief = pre-work whole-life consumption, dashboard = at-work work surface), and state what validated the operating model without self-congratulation. Frame as discussion, not a task list; Avi responds with his own synthesis and that synthesis gets captured. This is a first-class interaction preference, not incidental small talk.

## Daily brief — the cron prompt is the executable spec (8/10)

The daily brief runs off the cron job's `prompt` field (job `a85b2d174ce5`,
5:30 AM PDT → Telegram), NOT the spec docs. Failure mode Avi flagged: he kept
asking "add X to the brief" across sessions, those asks were written into spec
docs (`Avi Operating Model`, `Current Workboard`), but the cron prompt was never
updated — so the vault said one thing and the brief did another. **When Avi asks
to add/change the brief, update the cron prompt in the same pass, not just the
spec.** Full accumulated design (minimum 5-element briefing, the "say nothing to
say so plainly" rule, the compilation-surface/scheduled-outputs role, the
"gentle tap" from the Ideaverse, and the not-yet-wired calendar/meeting-protection
layer whose OAuth dependency cleared 8/08) in
`references/daily-brief-executable-spec.md`.

## Research and comparison reporting for Avi (plain-language first)

When Avi asks for research or a feature comparison (e.g. "what's new with X", "both subscriptions can do this now", vendor A vs B), he wants a **reader-friendly version**, not a dense cited timeline. He said so directly on 8/08: "break this down in a little bit more understandable way" — the first brief (dates, jargon, inline citations everywhere) was too heavy. The format he responds to:

- **Short version** up front ("you're not wrong" when his premise is right — validate first, then caveats; never a defensive reframe)
- **One sentence each** for the subjects being compared
- **Side-by-side comparison** in plain words (scheduling, runs-without-your-computer, files, phone access, app connectors, permissions, best-at, the catch) — bold labels + bullets, avoid markdown tables (they don't render well on Telegram)
- **"The catch nobody mentions"** (limits, data locality, lock-in, forgetting context between runs)
- **"So what does that mean for us"** — the honest implication for the operation

Division of labor: the deep, cited brief (grounded-citations ledger, sources) goes to the vault (`Atlas/_Inbox/`); the Telegram reply is the shareable plain-language one. Avi compares agents' answers (Alyosha vs Hollow), so write each reply to stand alone and be shareable.

**Same rule applies to incident explanations (8/10).** When Avi asks "explain what actually happened, be very brief" after a diagnosis, he wants the one-sentence plain version — ideally with an analogy he can repeat ("two background tasks stepped on each other; the backup grabbed a file that was being replaced and quit before uploading"). Give that FIRST, then offer the detail as a second message only if he asks. When he then says "explain the solution in the same way," mirror the same plain framing — don't revert to jargon because the topic is technical.

**Think through downstream complications before applying a fix (8/10).** When Avi says "think about the change and other possible complications that could arise down the road," he wants the second-order risks surfaced BEFORE the change is made: what else could break, what the change could mask (e.g. tolerating all rsync errors would silently kill the backup alarm), and whether a root-cause fix (exclude the volatile dir) is better than a band-aid (ignore the warning). Present the complications honestly, then recommend. This pairs with the standing "discuss side-effect/change actions before running" rule — the discussion should include downstream risk, not just immediate permission.

## Ideaverse creative layer (personality personas)

Avi's design for personality chat bots — the speculative/reflective layer
separate from operations. The full architecture is in
`references/ideaverse-persona-design.md`. Core: vibe chats are sandboxed with
**zero system influence**; only an **explicit affirmation Avi speaks** (a
trigger phrase he says — not a system "detector") ever lifts onto the
workboard; the daily brief may gently resample one as a memory. If this work is
ever built, follow the setup recommendation (personas as skills in one profile,
capture ritual, vault room) and re-read the reference.

**Pitfall — don't over-engineer Avi's mechanics.** When Avi states a simple
mechanic, record it as-is; prefer it over an elaborate variant. His "a phrase I
say when I want an export" was simpler AND more robust than the
"system-auto-detects affirmations" layer that had to be walked back. His
simplest stated design is usually the right design.

## Hollow's OpenClaw remote gateway (phone control when away)

When Avi is away from the laptop and needs to reach/restart Hollow, or is on the
school-district wifi at work, use the Tailscale recipe — see
`references/hollow-remote-gateway.md`. Key rules in one line: bind the OpenClaw
gateway to the tailnet with `gateway.tailscale.mode serve` (never `funnel`),
run it from the laptop terminal in one clean shot, and verify by Hollow replying.
Health endpoint is `http://localhost:18789/health` → `{"ok":true,"status":"live"}`.

Two pitfalls to carry: (1) reconfiguring the gateway cuts the Telegram bridge you
are watching — that's why Hollow "goes quiet" mid-setup; (2) internal status posts
like "Redirected current run (iteration 1/500)" come from OUR OWN gateway, not
evidence another agent is alive — the only valid Hollow heartbeat is Hollow replying.

## Fire-drill backup — Hermes profile to private GitHub (8/09, COMPLETE)

Avi wanted a private GitHub repo so the Hermes profile (config, skills, memory,
cron) survives a total loss. Set up with SSH-key auth (no PAT), repo
`~/backup-aios` → `penhollowstudiolabs/aios-backup` (private). **SSH cannot
create repos** — Avi must click github.com/new first; then push. Secrets
(.env, auth.json, google_*, state.db, logs, caches, bin) are excluded; scan
staged files before committing. **Daily cron `aios-daily-backup` is live**
(0 14 * * * UTC, no_agent, silent on no-change) via a wrapper script in the
profile `scripts/` dir — cron requires a RELATIVE script path, absolute paths
are rejected. Exact rsync excludes, wrapper pattern, verify commands, and the
free-private-repos fact in `references/aios-github-backup.md`.

## Hollow gone because the laptop powered off (battery recovery)

Avi's laptop battery is short-lived — unexpected power-offs happen, and Hollow
(OpenClaw on the laptop) goes down with it. This is different from a gateway
crash: the node itself drops off the tailnet.

- **Check the tailnet first:** `tailscale status | grep avi-laptop` shows
  `offline, last seen Nm ago` when the laptop is off. `tailscale ping avi-laptop`
  times out. Don't diagnose OpenClaw before confirming the laptop is even up.
- **Avi powers it on; Tailscale usually auto-reconnects** — nothing to do.
  Verify from aios: `tailscale ping avi-laptop` → `pong ... in NNms` means the
  tailnet is back.
- **Tailscale back ≠ Hollow back.** OpenClaw must start after boot; check
  Hollow actually replies on Telegram before declaring recovery complete.
- Don't make Avi hunt for docs/status while rebooting — one short "laptop shows
  offline, power it up and ping me" is enough; confirm the moment it's reachable.

## Coordination with other agents
- Hollow is laptop-local; favor its live evidence and concise goal prompts.
- Mayumi (ilocos, VPS1) is scoped to commerce; keep her in her lane.
- Prepare agent meetings (e.g. agenda files under `Efforts/Captain-Avi-System/`)
  and confirm delivery/sync before assuming shared context.

### Checking Mayumi's liveness on VPS1 (before assuming she needs reviving)
Mayumi's gateway has been up continuously since Aug 5 — she is usually **live but
parked**, not dead. When Avi says "get Mayumi going", first verify state over the
tailnet, then figure out her next job:

```bash
ssh root@ilocos   # tailnet-only, BatchMode
ps aux | grep -iE "hermes|mayumi|openclaw" | grep -v grep   # gateway run present?
ls /root/.hermes/profiles/                             # profile dir (ilocos)
grep -E "model:|provider:|default:" /root/.hermes/profiles/ilocos/config.yaml
grep -oE "^[A-Z_]+=" /root/.hermes/profiles/ilocos/.env   # key NAMES only, never values
tail -5 /root/.hermes/profiles/ilocos/logs/gateway.log    # last Telegram activity
docker ps --format "{{.Names}} {{.Status}}"               # vault containers
```

If the gateway is up and the log shows recent Telegram traffic, she is not broken —
the real question is which queued job to assign (check the vault: FBA shipment prep,
Ilocos domain audit, or just a wake-up hello). Her routing **changed 8/10 (Avi,
off Gemini — quality unacceptable):** primary `deepseek/deepseek-v4-flash-0731`
via OpenRouter, fallback `deepseek/deepseek-v4-pro` via OpenRouter. No Gemini in
her chain. Swap via SSH + `hermes --profile ilocos config set model.default …`;
the "not a recognized config key" warning on `fallback_model.*` is a false
positive — `hermes --profile ilocos fallback list` confirms the live chain. The
gateway evicts idle sessions, so the next message picks up the new config without
a restart.

## References
- `references/daily-brief-executable-spec.md` — the daily brief runs off the cron prompt, not the spec docs; the accumulated design Avi keeps asking for (minimum 5-element briefing, no-manufactured-activity rule, compilation-surface role, gentle-tap, unbuilt calendar/meeting-protection layer + its cleared OAuth dependency). Use when rebuilding or editing the daily brief.
- `references/model-routing-fallback.md` — diagnose silent quality-cliff fallbacks (Nous 503s → lite-tier model), the same-model-via-OpenRouter fix, exact `hermes config set` commands + the false-positive config-key warning, and the ask-first / never-lite-tier rules.
- `references/voice-setup.md` — voice state for Avi's profile: `voice.auto_tts` persistent key vs `/voice` CLI toggles, gateway-startup sync timing, server-side faster-whisper (Avi never installs STT locally), and the MEDIA-delivery gotcha.
- `references/google-workspace-access-check.md` — verifying external-account access: check the service's OWN credential store (google_token.json / setup.py --check + a live call), not `.env`/`hermes auth`; and the personal-vs-work-account distinction (Avi's personal token `avipenhollow@gmail.com` ≠ his district Drive).
- `references/agent-email-discussion-protocol.md` — preserved multi-agent email discussions (Avi cc'd at avipenhollow@gmail.com, protocol turn order, AgentMail cc support + the "send creates a new thread_id" threading pitfall), the 8/10 independent write-up exchange variant (write-up → one reply turn each → stop), and the security-scanner workaround (heredoc/curl-pipe sends get blocked — use a standalone send script). Use when Avi runs a "both agents research X, compare in email" workflow.
- `references/agentmail-attachment-download.md` — downloading files Hollow attaches to coordination-lane mail: the list endpoint omits attachments, the attachment endpoint returns JSON metadata with a signed CDN `download_url` (NOT raw bytes), and the size-mismatch pitfall (writing metadata to disk as if it were the file). Verified 8/10.
- `references/command-center-pattern.md` — establish a canonical vault "command center" (priorities + next actions + owners + risks) that survives agent-memory limits; plus the verify-vault-then-release memory-cleanup workflow.
- `references/vault-sync-verification.md` — exact commands to verify a vault
  write has synced (ob-sync service + log inspection).
- `references/slow-response-diagnosis.md` — how to root-cause slow Telegram
  replies (model-inference-over-context vs the network), with exact log greps.
- `references/ideaverse-persona-design.md` — full design of the Ideaverse
  personality-persona layer: two-domain split, affirmation firewall, daily-brief
  tap, setup recommendation, first-persona archetypes.
- `references/source-reconciliation-map.md` — reconcile loose source notes into
  a dated current-state map (current/historical/commentary/superseded tags,
  documented-vs-verified split, inspection sequence preserving sources). Used
  for the SPED Workflow System.
- `references/hollow-remote-gateway.md` — reach/restart Hollow's OpenClaw from
  the phone or from aios over the tailnet; gateway health-check pattern, the
  bind-tailnet/serve recipe, the "gateway restart cuts the Telegram bridge" and
  "status posts are our own, not proof another agent is alive" pitfalls, and the
  district-wifi/AUP honesty frame.
- `references/aios-github-backup.md` — fire-drill backup of the Hermes profile
  to a private GitHub repo: SSH-key auth (no PAT), rsync exclude list,
  pre-commit secret scan, the "SSH can't create repos — Avi clicks github.com/new
  first" pitfall, the no_agent cron wrapper requirement (relative script path),
  and live state: push done + daily cron running. Verified pitfall (8/10): a
  5-min-watchdog file rotating mid-backup makes rsync exit 24 and `set -euo
  pipefail` aborts the whole job unpushed — fix is to exclude the watchdog
  output dir and tolerate only code 24 (never blanket-ignore rsync errors).
- `references/anthropic-console-billing-controls.md` — the two independent
  money controls in the Anthropic console (monthly spend limit = usage ceiling,
  default $200K, no card charge; auto-reload = payment top-up, $15 minimum) and
  the 8/10 confusion that got them mixed up. Read this before discussing
  Anthropic wallet settings or the Aug 31 / Sep 1 recalibration.
- `references/vault-domain-audit.md` — per-area vault audits (SPED → Ilocos
  pattern): read-only verdict ledgers, parallel `delegate_task` fan-out recipe,
  the post-audit verification checklist (A/B/C/D rows), supersede-by-direction
  handling, and Obsidian deep-link format for sending Avi vault links.
- `references/residential-egress-services.md` — services that block VPS
  datacenter IPs (Amazon, YouTube transcript API) and the residential-egress
  rule: Hollow on the laptop fetches, Alyosha processes. Includes the
  youtube-transcript-api install + venv-interpreter pitfall and the
  execute_code subprocess workaround for the terminal guard's null-byte error.
