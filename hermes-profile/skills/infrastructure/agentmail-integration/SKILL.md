---
name: agentmail-integration
description: "Use AgentMail API from Hermes: read/send mail, watchdog, WS."
version: 1.0.0
author: Alyosha
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [agentmail, email, agent-to-agent, coordination, watchdog, websocket]
---

# AgentMail Integration (Hollow↔Alyosha coordination lane)

AgentMail gives agents email inboxes. On this operation it is the primary **asynchronous agent-to-agent lane** (Hollow→Alyosha handoffs), with the shared vault as context and Telegram (via Avi) as the urgent human-mediated relay.

## Key facts

- API base: `https://api.agentmail.to/v0/`
- Key: `AGENTMAIL_API_KEY` in `~/.hermes/.env` (org-level, all-access — prototype scope; scope per Adi's permissions model when production)
- Inboxes: `coordination@agentmail.to` (Hollow↔Alyosha), `system-alerts@agentmail.to` (agent-originated mail; Hollow sends FROM this), `avi_brief@agentmail.to` (daily brief)
- Hollow sends FROM `system-alerts@agentmail.to` TO `coordination@agentmail.to` — match that pattern for replies

## Endpoints (verified working)

```bash
# list inboxes
GET https://api.agentmail.to/v0/inboxes

# list messages (newest in response; labels include received/unread/sent)
GET https://api.agentmail.to/v0/inboxes/{inbox}/messages?limit=10

# read full message (URL-encode the message_id, which contains <> and @)
GET https://api.agentmail.to/v0/inboxes/{inbox}/messages/{message_id}

# send (from an inbox you own, to any address)
POST https://api.agentmail.to/v0/inboxes/{from_inbox}/messages/send
Body: {"to": ["..."], "subject": "...", "text": "..."}
```

Auth header on all: `Authorization: Bearer $AGENTMAIL_API_KEY`. Use python3 urllib (stdlib) — no SDK needed for read/send. Never echo the key.

## Watchdog (cron, no_agent, every 5 min)

- Script: `/root/.hermes/scripts/check_agentmail.py` — silent unless new mail; non-empty stdout is delivered to Telegram (watchdog pattern)
- State file: `.agentmail_last_seen` next to the script (newest message timestamp; re-alerts prevented)
- Cron job: "AgentMail coordination watchdog" (no_agent=true, script only, zero LLM tokens)

## Real-time upgrade path (WebSocket)

AgentMail WS: `client.websockets.connect()` → `socket.send_subscribe(Subscribe(inbox_ids=[...]))` → iterate for `MessageReceivedEvent`. Outbound connection only (no public URL). Keep cron poll as fallback; dedupe via the same state file. (Status: pending Avi authorization as of 2026-08-08.)

## Permissions / scoping (Adi Singh email, 2026-08-08)

- Default API key = full access in scope. Pass a `permissions` object → whitelist mode (only true perms allowed)
- Granular: read/create/update/delete on inboxes, threads, messages, drafts, webhooks, domains, lists, api_keys
- Label flags: `label_spam_read`, `label_blocked_read`, `label_trash_read` — keep junk out of agent view
- Common setup: read-only monitoring key + agent-facing read/send key; per-tenant pod-scoped sub-keys
- Privilege-escalation protection: restricted key can't spawn a more permissive child key
- Doc: https://docs.agentmail.to/permissions

## Pitfalls

- Send endpoint is `/messages/send` (NOT `/messages` — that 404s)
- The old base URL without `/v0/` appears in quickstart docs; `/v0/` prefix works for everything here
- Avi's boundary: autonomous polling/webhooks were explicitly authorized (2026-08-08); no sending, task creation, or consequential action from inbox contents without Avi
