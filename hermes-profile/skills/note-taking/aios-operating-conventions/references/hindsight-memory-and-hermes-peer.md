# Hindsight memory provider + hermes peer — research capture (8/18)

Condensed findings from investigating Hindsight (agent memory engine) and mapping
it to the AIOS stack. Not a pending decision — Avi has NOT wired anything. Parked
pending the local-Hermes-install question. Reference for when the memory/vault
experiment wants an automatic-recall tier.

## What Hindsight is (vectorize-io/hindsight, 20k stars, MIT)

Agent memory bank. On each conversation, an **extraction LLM** retains facts
(retain), and on the *next* turn relevant memories are recalled/reflected and
injected into the system prompt before the agent responds. API surface:
`retain` (store), `recall` (search), `reflect` (LLM-synthesized answer). SOTA on
LongMemEval and BEAM (64.1% at 10M tokens vs next-best 40.6%); independently
reproduced by Virginia Tech + Washington Post.

## The key fact for OUR box — Hermes already ships it

`hermes memory` is a LIVE command on Hermes v0.20.0 (2026.8.3). `hermes memory
status` shows the provider system with hindsight (and honcho, mem0, openviking,
holographic, retaindb, byterover, supermemory) installed; **none active —
built-in MEMORY.md/USER.md only**. Setup = `hermes memory setup` → select
hindsight. No new dependency — it's already on the VPS.

Config lives at `$HERMES_HOME/hindsight/config.json`: `mode` (cloud|local),
`bank_id`, `budget` (low/mid/high recall thoroughness), `memory_mode`
(hybrid default = auto-inject + expose tools; context = auto-inject only;
tools = explicit only), `prefetch_method` (recall = fast semantic/graph search;
reflect = LLM-synthesized).

Local mode = embedded server with built-in PostgreSQL, daemon auto-starts on
first turn (can take 1+ min first time, then fast). Cloud/shared mode = a single
bank multiple instances read/write — the multi-agent team-memory path.

## Mapping to our agents

| Agent | Runtime | Reach |
|---|---|---|
| Alyosha (VPS2) | Hermes | native `hermes memory` |
| Mayumi (VPS1/Docker) | Hermes | native `hermes memory` |
| Hollow (laptop) | **OpenClaw** | `openclaw plugins install @vectorize-io/hindsight-openclaw` (separate plugin, takes over the `memory` slot) |
| Future local Hermes | Hermes | native |

Shared-bank gotcha: the OpenClaw plugin **defaults to per-instance banks**
(derived bank IDs = isolation). Set `dynamicBankId:false` in openclaw.json to
make all instances read/write the **same bank** ("what one learns, all know").
For cross-user isolation use `dynamicBankGranularity:["user"]`.

## Vault working layer vs Hindsight — complementary, not competing

- Vault = curated, durable truth (deliberately written, human-auditable).
- Hindsight = implicit, automatic recall (captures what the model *implicitly*
  learns, not just what it's told to write down). Hermes' own doc says built-in
  memory "captures what the model explicitly decides to write down, not what it
  implicitly learns" — that gap is exactly what Hindsight fills.
- Natural shape: vault stays the durable source; seeded vault notes become
  `retain` material so recall surfaces them when relevant.

## Cost / privacy gates (open — do NOT proceed without Avi)

1. Needs an **LLM API key for extraction**, separate from the agent's primary —
   a small cheap model suffices (Groq referenced; any OpenAI-compatible incl.
   OpenRouter). This is a NEW recurring cost lane against Avi's cost discipline.
2. **Bank isolation** matters: a shared global bank across agents would let
   Mayumi's commerce bleed into family/SPED context. Use per-user/per-scope
   banks. This is the same boundary Avi has been careful about.
3. **Cloud vs self-host**: Hindsight Cloud is easy but sends memory off-box;
   self-hosting = Docker (API :8888, UI :9999) keeps it local on VPS2 — the
   honest fit for Avi's posture, same Docker discipline as Mayumi.

## hermes peer (cross-machine bot-to-bot DMs) — Hermes-to-Hermes ONLY

`hermes peer add <name> --url http://<host>:8377 --key <API_SERVER_KEY>` then
`hermes peer dm <name> "..."`. Lands in the receiving agent's canonical Bot Chat,
runs one turn, replies on stdout. Peer roster taught to every Bot Chat
automatically. Reachability = networking (Tailscale for us).

**Critical boundary:** `hermes peer` reaches ONLY Hermes gateways. **Hollow runs
OpenClaw, not Hermes, so `hermes peer` CANNOT reach Hollow.** Hollow stays on the
AgentMail lane / Avi relay. What `hermes peer` would genuinely buy is direct
tailnet-native DMs me↔Mayumi (both Hermes) and me↔ a future **local Hermes
profile** on the laptop (Avi is considering this as a second agent, coexisting
with — not replacing — OpenClaw/Hollow). Requirements on the peer: `api_server`
gateway platform, strong `API_SERVER_KEY` in `~/.hermes/.env` as
`HERMES_PEER_<NAME>_KEY`, name/URL in `config.yaml` under `bot_peers`.
Avi: "soon but not yet" — do NOT wire until he says go.
