# Council prep: model readiness & agent reachability (2026-09-04)

Session learnings while Avi convened a full-fleet council (Alyosha / Hollow / Mayumi /
Dewey / Avi) over AgentMail for a business-plan discussion.

## Dewey is reached by the cc'd Gmail, not purely Avi-relay
- Every council round already cc's `avipenhollow@gmail.com`. Dewey reads that inbox,
  so the **cc delivers the agenda to him directly** — no extra leg needed to get it to him.
- The real question is his **return leg**. Confirm per council which of:
  (a) he replies in-thread from that Gmail to `coordination@` (if it can send),
  (b) he writes to the synced vault and Alyosha picks it up,
  (c) Avi pastes his input.
- Do not treat Dewey as simply "inbox-less / Avi-relay only." For this council he was a
  mostly-observing participant (questions only), so a full return channel was low-stakes —
  but the routing fact (cc → his Gmail) is durable.

## Model readiness check before a reasoning-heavy council
A strategic/direction council is where cheap inference does the most damage: the failure
is in the connections between facts, not the facts, so a flash model produces confident
but shallow synthesis that is hard to catch. Run the check BEFORE opening the round:

1. **Read only the canonical routing source:**
   `Efforts/Captain-Avi-System/Model-Token-Usage-Tracking.md`
   (in `/root/vault`). It is THE single authoritative per-agent model/provider/fallback
   record; other files point to it. Do not guess routing from memory.
2. **Identify who is already adequate** so you don't over-correct. As of 2026-09-04:
   - Hollow (laptop): `openai/gpt-5.6-sol` — already high-reasoning. No change.
   - Alyosha (VPS2): `deepseek/deepseek-v4-flash-0731` — flash tier (the gap).
   - Mayumi (VPS1): `deepseek/deepseek-v4-flash-0731` — flash tier (the gap).
   - Dewey: routing AWAITING Avi (observer anyway this round).

## Per-agent model override is LOCAL ONLY
- Alyosha controls the config on **VPS2 (his own machine) only.** There is NO SSH from
  VPS2 to VPS1 (Mayumi) or to the laptop (Hollow); reach is AgentMail + the ilocos peer
  gateway only. He cannot flip a remote agent's model himself — do not claim you can.
- To get remote discussants onto a high-reasoning model, choose one of:
  - **(a) Avi drives the override on each remote machine** for the council window
    (highest certainty), then reverts after; or
  - **(b) the opening round carries a directive** to answer on a named model
    (e.g. Mayumi → `deepseek/deepseek-v4-pro`, in-family) and Alyosha **verifies
    compliance against the canonical table after round 1** before deepening the discussion.
- Do not fire a round assuming remote agents silently run high-reasoning; you find out
  mid-deliberation otherwise.

## Cost / authorization guardrails (Avi's standing rules)
- Routing is **Avi's lane**: get explicit sign-off before any override.
- Any config change must update the canonical routing table **in the same session**.
- Prefer **in-family** upgrades (flash → pro, same provider) over new paid-heavy lanes;
  revert after the council. Alyosha should not draw GPT-sub quota (that is Hollow's lane).
- Local override mechanics on VPS2: config at `~/.hermes/config.yaml`
  (`model.default` + `model.provider`, fallback under `fallback_providers:`);
  `hermes config show` reflects the active model. Per-chat/runtime override can differ
  from the config default — distinguish them.
