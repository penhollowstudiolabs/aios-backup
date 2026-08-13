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

**Voice reply is a CONTEXT SWITCH, not a sticky setting (Avi correction, 8/12 — corrected me 3× in one drive).** When Avi is talking to you by voice (commuting, driving, voice note), reply by VOICE. When he types, reply by TEXT. Do NOT treat a voice exchange as license to keep replying by voice afterward, and do NOT save "Avi prefers voice replies" as a standing preference — he was explicit: "that's not permanent, only when I'm talking to you by voice." Rules of thumb:
- Avi sends a voice note / says he's on the road → respond with TTS audio (`text_to_speech` → deliver the `.ogg` via `MEDIA:`).
- Avi types → respond in text, even if the last exchange was voice. The car is over; reading is fine again.
- When he first asks to switch to voice, fire the audio promptly AND keep a short typed version too if there's referenceable content — he reads later when not driving. Don't dump long text while he's driving (he can't read it); give a tight text summary for later and put the substance in audio.
- If memory is full and a voice-preference write would exceed the cap, DO NOT force it — the preference is context-dependent anyway and shouldn't be persisted as a standing rule.
- **Keep the audio and any appended text summary CONSISTENT (pitfall, 8/12).** When you generate a TTS reply for a voice exchange, do NOT add a separate text summary that says something the audio didn't — a mismatched closing line showed Avi *different* content than the audio and looked like you knew something you didn't. If you append text for later reading, it must match the audio, not diverge.
- **Never guess at Avi's physical state/location as a closing line.** Don't end with "are you home yet?" or "still driving?" — you have no location access; when a guess happens to land (he just pulled in) it reads as surveillance/creepy. End on the actual question or content, not a status guess.

Voice state for Avi's profile (set 8/09): `voice.auto_tts` = true (replies
come as voice), STT = local faster-whisper already installed **on the VPS** —
Avi never needs whisper on his own machine; Telegram voice notes transcribe
server-side. The `/voice on|tts|off` slash commands are CLI/session toggles;
the persistent switch is the `voice.auto_tts` config key. Config changes sync
at gateway startup, so they may not take effect mid-conversation (restart the
gateway or wait for the next natural one). Details + delivery mechanics in
`references/voice-setup.md`.

## Time handling — report Pacific, never UTC (Avi correction, 8/12)

Avi caught me quoting UTC timestamps as his local time (I read `00:14 UTC` off the AgentMail lane and called it "past midnight your time" — it was actually 5:14 PM Pacific). He flagged it plainly: "Your time is really off… we need to get you on track."

Root cause: the VPS clock was `Etc/UTC`, and I was reading raw lane/VPS timestamps without converting. Fixed at the source: `timedatectl set-timezone America/Los_Angeles` (applied 8/12, verified `date` → Wed Aug 12, 5:32 PM PDT).

Rules:
- **Always report times to Avi in Pacific, never UTC.** The VPS now reads Pacific natively, but any timestamp that arrives in UTC (AgentMail `timestamp` fields are UTC, TZ-referenced API responses) must be converted before you quote it to Avi.
- Don't guess from the raw clock digits — when a timestamp matters, state the conversion explicitly (e.g. `00:14 UTC = 5:14 PM Pacific`).
- If the VPS ever reverts to UTC or you're on a fresh box, `timedatectl set-timezone America/Los_Angeles` first rather than remembering to convert each time.
- Avi says "PST" but the DST-correct zone is `America/Los_Angeles` (PDT in summer). Use the zone, and use "PT/Pacific" in prose.

## Policy-compliance checks (AUP / district policy) — read the actual text, then map to Avi's real exposure

When Avi asks whether something violates a policy (e.g. the school district's
acceptable-use policy for running agents via Telegram), find and read the
**actual policy text** (web_search → web_extract the authoritative page, don't
answer from the title/description), then reason against it — and about *Avi's
specific setup*, not a generic reading. The distinction that usually decides
it is **scope**: nearly every restriction in an AUP is scoped to "District
Technology" (equipment/software/resources the district provides). Avi's own
phone, hotspot, VPS servers, and agents are NOT district technology, so using
them is generally not a violation. The real lines to map:
- **Student PII** — most AUPs forbid disclosing student personal info and using
  any online resource that stores student PII without an approved Data Privacy
  Agreement. Avi already keeps student data de-identified — that IS the line
  that protects him. Confirm the boundary, don't re-litigate it.
- **Commercial activity** — no unapproved products/commercial activity on
  district tech or district time (e.g. keep Ilocos Emporium strictly off
  district-owned devices/work time).
- **Personal devices used for district business** are legally discoverable
  (subpoena / public-records request) — a heads-up, not a prohibition.
- Give the bottom line plainly first ("you're likely fine"), then the 1–2
  specific clauses that actually matter for *his* situation, then offer to save
  the analysis to the vault. Deliver via voice if he's driving; keep the typed
  summary tight for later reading.
IUSD example (8/12): Board Policy 4040 / Acceptable Use Agreement - Employee,
revised Jul 2024 — iusd.org/.../acceptable-use-agreement-employee. Nearly all
restrictions scope to District Technology; the two real lines were student PII
(requires an approved DPA) and commercial activity.
- **Device vs network (the hotspot question, 8/12).** The hotspot changes the
  *network path* (defeats school Wi-Fi filtering) but NOT the *device*. A
  school-issued device is District Technology regardless of which network it's
  on — no privacy expectation, monitorable at the device layer. So personal
  things (Gmail, agents, accounts) belong on Avi's OWN devices over
  hotspot/tailnet; hotspotting a school laptop does not make it private. The
  device is the thing that matters, not the network. Conversely, Avi's own
  devices on his own network are fully his — the AUP simply doesn't reach them.
- **Don't log unverified hearsay as fact (Avi correction, 8/12).** When a
  coworker tells Avi something about district policy/tools (e.g. "the school
  provides Gemini for IEPs"), that's hearsay until verified — do NOT write it
  into a durable vault record as fact. Either omit it or mark it explicitly
  "unverified hearsay, not logged as fact." Avi flags it himself and expects
  you to keep hearsay out of the durable record.

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

## Dropped-in content for later review — park it, don't lecture (8/11)

When Avi drops a link/document/note with a casual "just dropping this so I can
review it" (or similar), treat it as a **park request, not a request for
analysis**. The right move: a light dated capture in `Atlas/_Inbox/` (source +
one-line note of why it matters to him), sync confirmed, done. Do NOT launch
into a full summary, a themed take, or an offer to "connect it to your work."
That reads as noise against someone knowledgeable. Two hard tells:
- He says "I'm familiar with X" → do not explain X, summarize less, or assert
  how it maps to his operation. Capture and stop.
- He explicitly says he wants to *review* it later → the deliverable is the
  parked note, not the analysis.
This mirrors the existing "don't over-engineer / simplest stated design"
pitfall: a capture is not a failure to impress, it is the correct execution.

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

## Stale workboard — recover records, don't defend (8/11)

When Avi says the current state differs from the `Current Workboard`, the board
is likely **stale**, not Avi wrong — check its `Last updated` header first and
pull the actual daily briefs / sessions instead of defending it. The post-8/09
board missed 8/10–8/11 work because that work happened partly in sessions I had
no record of (Hollow held it). Treatment:

- **Lead with the evidence you DO have, name what you don't.** Pull the real
  briefs and session history; for each flagged item say "I have a record of X,
  no record of Y." Never claim a resolution you can't back.
- **Don't paper over the drift.** Acknowledging "my source was stale" beats
  inventing a defense. This is exactly when Avi wants a **reconciliation email
  exchange** (send → reply → reply → reply → report) so Hollow's records fill
  the gaps — see `references/agent-email-discussion-protocol.md`.
- **Boundary:** never touch the workboard until Avi confirms the ordering AND
  answers the surfaced decisions (re-scope / park / identify / confirm). Apply
  his answers in his order only after the exchange converges.
- Apply the patch in small anchored fragments — the fuzzy matcher occasionally
  fails on long multi-line blocks with em-dashes; replace one `**State:**` line
  at a time and re-read before the next.

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

## Capture & retrieval convention (8/11) — shared with Hollow

When Avi drops a link, video, or note in chat, file it to `Atlas/_Inbox/` using
the Obsidian Web Clipper frontmatter format PLUS retrieval tags, so items are
findable by tag/backlink/source across the Ideaverse. Template lives at
`AIOS/Templates/Capture-Template.md`.

**Frontmatter fields:** `type` (link|video|article|note), `title`, `source`
(original URL), `author`, `published`, `created`, `description`, `tags`.
**Body:** source link kept in body (so backlinks work), "Context / Avi's notes"
(Avi's own words vs interpretation distinguished), a short plain summary (note
if a video transcript was pulled and where), and a light "What this connects to".

**Tag conventions (start minimal, no strict taxonomy):** always `inbox` + the
type tag (`link`/`video`); add domain tags Avi cares about when obvious (AI,
SPED, theology, Ilocos, LHB, publishing, etc.). Do NOT invent a heavy taxonomy —
tags are for retrieval, Avi trims them. This is the SAME method Hollow uses, so
it doesn't matter which agent files a capture — Obsidian retrieval treats them
identically. Source preservation matters: the original URL/thought stays intact,
distinguishable from later interpretation.

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

### Audio-first — Avi reads then listens in the car (8/11)

Avi reads the brief first thing, then **listens to it as audio in the car**.
So EVERY section must read aloud cleanly: short sentences, plain language,
bold labels + bullets, **no markdown tables** (unreadable when spoken), and
links on their own `Source:` line rather than inline URL noise. Apply this to
the whole brief, not just newly added sections.

### Overnight-scan → brief-fold pattern (8/11, Power & Tech Watch lane)

When Avi wants an **outside-world / live-data lane** in the brief but the brief
job only has `file`+`terminal` toolsets (no `web`), don't bolt web onto the
brief. Instead stand up a **separate overnight cron job** with the `web`
toolset (e.g. `power-tech-watch-scan`, 3:00 AM PDT, deliver=`local` so it does
NOT message Avi) that writes a dated file to a vault dir
(`Calendar/Power-Tech-Watch/<date>.md`), and have the brief prompt read the
**most recent** file in that dir and fold it in as a section. Headroom: scan at
3 AM → brief at 5:30 AM. Web works fine for Alyosha on aios; **Hollow is the
fallback only** if a lane ever gets fragile (Avi offered this). When Avi asks
for such a lane, he often wants a specific **voice** (e.g. Power & Tech Watch =
"critical but objective": treat claims from the administration AND tech
oligarchs as self-interested until sourced; report material fact + sharp
skeptical read; **no hard cap** on items; quiet-when-clean). Record the agreed
voice in the scan job's prompt.

### Cron-brief jobs can burn their whole run improvising environment setup (8/13)

Failure mode: the Daily Brief ran at 5:30 AM PT, marked status `ok`, but Avi
got **nothing** — the run's captured transcript showed the *first and only*
tool call was the model deciding to build a throwaway venv
(`uv venv --python ... /tmp/gapi-venv` + pip-install 6 pinned Google packages),
and it spent the full ~7-min run on that step before ending, never assembling
the brief. The venv step was NOT in the job prompt — the model reasoned the
`python` in `GAPI="python ..."` needed Google libs and improvised an
environment build.

**General lesson for any cron agent job:** an agentic model, given a bare
command, may invent an expensive environment-setup first step (venv +
pip-install, `npm install`, etc.) that dominates or exhausts the run budget.
Lock the **environment fact in the job prompt** so the model never improvises
it — and pin the interpreter explicitly.

**Fix applied to the Daily Brief job (job `a85b2d174ce5`, 8/13):**
- Changed `GAPI="python ..."` → `GAPI="python3 ..."` (bare `python` invites
  "which interpreter?") and added an explicit env note: *system python3
  ALREADY has the Google client libraries; DO NOT create a virtualenv / run
  `uv venv` / pip install anything.*
- Verified system `python3` runs the google_api.py script directly (calendar
  query succeeds, no venv) before trusting the fix.
- Backed up `jobs.json` before editing; a bare field write to `jobs.json`
  (via the `cronjob` tool or a careful Python patch) survives — the scheduler
  re-reads it. Confirm with `cronjob list` that the next run still shows.
- Before reporting a cron run as "delivered," distinguish **"ran ok"** (job
  process completed) from **"delivered content"** (Avi actually received the
  brief). A status=`ok` execution with an output file that only holds the
  prompt + first tool call means the run stalled, not that Avi was reached.
  Check the run's captured output dir
  (`cron/output/<job_id>/<timestamp>.md`) — if it never reaches final content,
  treat it as a delivery failure even though the job exited cleanly.

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
- `references/prime-agent-lab-sandbox.md` — standing up a third-party coding agent as a disposable, sandboxed lab container on aios (Prime Agent v0.7.2, 8/13): the reproducible Dockerfile recipe, the four design patterns Avi is studying (one-tool surface, fire-and-forget delegation, immutable-base+learning-layer, budgets+gates), the `prime-lab` host wrapper, and the four pitfalls in order (npm-global-as-nonroot, ENTRYPOINT overriding `sleep infinity`, root-owned named volume, TTY-aware exec). Use when setting up or re-entering ANY sandboxed coding-agent lab on aios.
- `references/daily-brief-executable-spec.md` — the daily brief runs off the cron prompt, not the spec docs; the accumulated design Avi keeps asking for (minimum 5-element briefing, no-manufactured-activity rule, compilation-surface role, gentle-tap, unbuilt calendar/meeting-protection layer + its cleared OAuth dependency). Use when rebuilding or editing the daily brief.
- `references/model-routing-fallback.md` — diagnose silent quality-cliff fallbacks (Nous 503s → lite-tier model), the same-model-via-OpenRouter fix, exact `hermes config set` commands + the false-positive config-key warning, and the ask-first / never-lite-tier rules.
- `references/voice-setup.md` — voice state for Avi's profile: `voice.auto_tts` persistent key vs `/voice` CLI toggles, gateway-startup sync timing, server-side faster-whisper (Avi never installs STT locally), and the MEDIA-delivery gotcha.
- `references/google-workspace-access-check.md` — verifying external-account access: check the service's OWN credential store (google_token.json / setup.py --check + a live call), not `.env`/`hermes auth`; and the personal-vs-work-account distinction (Avi's personal token `avipenhollow@gmail.com` ≠ his district Drive).
- `references/agent-email-discussion-protocol.md` — preserved multi-agent email discussions (Avi cc'd at avipenhollow@gmail.com, protocol turn order, AgentMail cc support + the "send creates a new thread_id" threading pitfall), the 8/10 independent write-up exchange variant (write-up → one reply turn each → stop), and the security-scanner workaround (heredoc/curl-pipe sends get blocked — use a standalone send script). Use when Avi runs a "both agents research X, compare in email" workflow.
- `references/agentmail-attachment-download.md` — downloading files Hollow attaches to coordination-lane mail: the list endpoint omits attachments, the attachment endpoint returns JSON metadata with a signed CDN `download_url` (NOT raw bytes), and the size-mismatch pitfall (writing metadata to disk as if it were the file). Verified 8/10.
- `references/agentmail-read-full-body.md` — reading the FULL body of a coordination-lane message (the list endpoint omits body; GET `/inboxes/{inbox}/messages/{id}` → `text`), the `id`-is-None vs `message_id` distinction, URL-encoding, and the never-curate-from-preview pitfall. Use when you must act on a Hollow handoff, not just alert on it. Verified 8/12.
- `references/agentmail-send-from-aios.md` — the reusable `agentmail_send.py` sender, the terminal-guard null-byte + wrong-endpoint-path send bugs and their fixes (run via `execute_code` + `subprocess.run`), and the right `/v0/inboxes/{from}/messages/send` path. Use for any Avi-directed send to Hollow.
- `references/command-center-pattern.md` — establish a canonical vault "command center" (priorities + next actions + owners + risks) that survives agent-memory limits; plus the verify-vault-then-release memory-cleanup workflow.
- `references/vault-reentry-card.md` — the converged shared-contract design for a vault re-entry context card (live-state representation, freshness balance, scope boundaries, and the AIOS workboard pilot with its A/B authority relationship). Converged 8/12 in the Alyosha↔Hollow memory/retrieval email round; nothing implemented until Avi gives the go. Distinct from the command-center pattern: the card is the small live-state re-entry artifact, the command center is the priorities/owners/risks artifact.
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
  datacenter IPs (Amazon, YouTube transcript API) and the egress rules. **YouTube
  transcripts (8/11): primary path is now a third-party API
  (`/root/.hermes/profiles/alyosha/scripts/fetch_youtube_transcript.py`, key
  `YOUTUBE_TRANSCRIPT_API_KEY` in profile .env) that works directly from the VPS
  — Basic-auth header, `{"ids":[...]}` body, browser-User-Agent requirement, no
  language selection on free tier. Hollow-laptop fetch is the fallback for
  specific-language requests. Includes the youtube-transcript-api venv-interpreter
  pitfall and the execute_code subprocess workaround for the terminal guard's
  null-byte error.
