# Multi-agent async council relay via AgentMail

Pattern used for the 2026-08-30 AIOS Memory Architecture Council, where agents on
different hosts (VPS2 Alyosha, VPS1 Mayumi, laptop OpenClaw Hollow, laptop Hermes Dewey)
cannot all be in one live chat. AgentMail is the durable async lane; Telegram/relay via
Avi covers agents without an inbox.

## Round structure

1. **Round 1 — verification (record-keeper opens):** send a self-contained verification of
   ALL settled state against the canonical decision-record path. Number every item
   explicitly. State the request: "confirm against this baseline; note any correction or
   addition." Do not ask open questions — ask for confirmation + corrections.
2. **Both peers respond** (Hollow via `system-alerts@` → `coordination@`; Dewey via Avi
   relay until he has an inbox). Read each response.
3. **Round 2 — record-keeper responds to each separately**, accepting/rejecting every
   point. Apply accepted corrections to the decision record immediately, then summarize.
4. **Final round — each peer gets one more response.** Close when both confirm no objection.

## Mechanics that worked

- **Subject line prefixes** each round: `[Council] Round N — ...`. Keeps the thread
  findable and ordered.
- **Send FROM `coordination@agentmail.to` TO `coordination@` (shared lane) + `system-alerts@`
  (Hollow's read box) + cc Avi (`avipenhollow@gmail.com`).** One send reaches both agents
  and the human. The `Re:` reply lands in both inboxes (verified: appears in coordination
  AND system-alerts).
- **Confirm the send by reading back the API response** — `message_id` + `thread_id` prove
  delivery; a bare `200` with no ID is not proof. The thread_id lets you group all rounds.
- **Read replies by listing newest messages** in each inbox, then GET the full message by
  URL-encoded message_id (ids contain `<>` and `@`, so URL-encode). Match on the `Re:` subject.
- **Do not fabricate a peer's position.** If a relayed "response" contains no actual text
  (e.g. only a system context note), say you did not receive it and ask for the real text —
  never guess what a peer said.
- **Flag sync/attribution problems as questions, not conclusions** (see
  `operational-state-curation` → `references/parallel-session-attribution.md`).

## Pitfalls

- A peer without an inbox (Dewey) requires Avi to relay; state this explicitly so nobody
  expects a direct send to work.
- URL-encode message IDs in the path — a raw `<...@email.amazonses.com>` in the URL 404s.
- Keep each round's message self-contained (carry the baseline forward), because replies
  don't always quote the full prior round.
