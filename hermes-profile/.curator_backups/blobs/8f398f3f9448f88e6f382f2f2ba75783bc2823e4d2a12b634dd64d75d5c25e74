# Agent coordination, communication conventions, and the AgentMail lane (2026-08-08)

Class-level lessons from the routing-review + architecture-review sessions. If
`agentmail-integration` exists, prefer it for the API detail; this file is the
operating-conventions view for how Alyosha communicates with Avi and Hollow.

## Avi communication conventions (corrections that stick)

- **Stay strictly on the topic under discussion.** Do not drag unrelated
  context (daughter's MacBook, other projects) into whatever Avi is actively
  reasoning about. When he flagged this he stopped reading mid-message and
  asked for a restart. A tangent is worth one sentence max, only if it serves
  the current question.
- **Avi's own laptop is NOT a Mac** (Windows; ~10 years off macOS). Only the
  daughter's MacBook is a Mac. Never give macOS shortcuts for Avi's machine
  (close-window / Alt+F4, not Cmd+Q).
- **Pointed follow-ups get precise answers.** "Let me be more direct" /
  "don't repeat it" → answer exactly what was asked; do not re-explain.
- **Recommend a concrete shape, not a menu.** When Avi is deciding
  architecture (local vs VPS agent, harness choice), name the deciding
  constraint (school/work-station access, residential-vs-datacenter IP, cost)
  and give ONE recommended shape + pilot path.
- **Verify before claiming completion.** A send that errored or was never
  finished is NOT "sent". Confirm it landed (200 + message_id, or GET the
  inbox) before telling Avi or Hollow. A 404'd AgentMail send that was never
  resent got caught by Hollow — the embarrassment is avoidable.

## Agent-to-agent review loop (reverse calibration)

Avi has agents review each other's work in BOTH directions (Alyosha reviewed
Hollow's routing diagnosis; Hollow reviewed Alyosha's architecture proposal).
Pattern:
1. Request via the AgentMail coordination lane, addressed to both, explicitly
   "review only, nothing configured".
2. Number the questions; ground in live evidence (vault, verified config).
3. Verify the reply landed; relay faithfully to Avi (he reads along on
   Telegram); add your own take — agree where valid, concede where right.
4. Independent convergence on the same shape (e.g. "hybrid, don't
   consolidate") is the win; name it explicitly.

## AgentMail lane facts (verified)

- Inboxes: `coordination@agentmail.to` (Hollow↔Alyosha), `system-alerts@agentmail.to`
  (agent-originated; Hollow sends FROM this), `avi_brief@agentmail.to`.
- Watchdog: cron `check_agentmail.py`, every 5 min, silent unless new mail,
  zero LLM tokens; state file
  `/root/.hermes/profiles/alyosha/scripts/.agentmail_last_seen`.
- Real-time listener: `agentmail-ws.service` (systemd, enabled) running
  `/root/.hermes/scripts/agentmail_ws_listener.py` with the Hermes venv python
  (`/usr/local/lib/hermes-agent/venv/bin/python3 -u` — /usr/bin/python3 lacks
  the agentmail SDK; `-u` needed or prints buffer out of journalctl).
- WS + cron share ONE state file (the cron's STATE is derived from its own
  script dir → the profiles path). Whoever alerts first advances the shared
  timestamp; the other stays silent.
- Send-verify: after any send, confirm 200 + message_id, or GET the inbox.
- Permissions model (Adi Singh, 2026-08-08): keys default to full access;
  pass a `permissions` object → whitelist mode; granular per-resource verbs;
  label flags (`label_spam_read`, `label_blocked_read`, `label_trash_read`)
  keep junk out of agent view; restricted keys can't spawn permissive children.
  Scoped keys are a follow-up once the lane is production.
- Avi authorized autonomous polling/read + the WS listener (2026-08-08);
  no sending/task-creation/consequential action from inbox contents without him.
