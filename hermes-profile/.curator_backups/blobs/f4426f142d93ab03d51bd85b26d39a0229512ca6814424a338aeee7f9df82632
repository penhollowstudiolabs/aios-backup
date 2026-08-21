# AgentMail: scoped access + inbox lifecycle (8/15)

## Scoped keys + native send allowlists — better than a custom relay

When an agent (e.g. Mayumi) needs mailbox access WITHOUT the org-wide key, do NOT
build a hand-rolled relay/wrapper. AgentMail natively supports both halves of the
boundary (Hollow-verified, 8/15):

- **Inbox-scoped sub-keys with a `permissions` whitelist.** Generate a sub-key
  limited to ONE inbox (e.g. `mayumi-ilocos@agentmail.to`) with only the perms it
  needs: read messages, send messages, create/update drafts. Explicitly DENY inbox
  management, deletion, API-key management, list management, and draft-send. A
  restricted key also cannot spawn a more permissive child key (privilege-
  escalation protection). Tighter and less to maintain than a wrapper around the
  org key.
- **Native inbox-level send allowlist.** Enforce "internal autonomous, external
  approval-gated" WITHOUT code: set the inbox send allowlist to internal addresses
  only (Avi, Alyosha, Hollow). With an allowlist, Mayumi can **draft** to an
  external customer/vendor but her key CANNOT send it — an approved privileged
  path (org key / send perm on another identity) sends afterward. This removes a
  custom relay's only real job (external-send gating).

Rules:
- Keep the org key (`AGENTMAIL_API_KEY`) on aios/Alyosha only; never hand it to a
  scoped agent.
- Prefer scoped key + native send allowlist; add a custom wrapper ONLY if native
  controls fail a live test (Hollow's verdict, 8/15).
- Same pattern applies to `avi_brief` if it stays.

## Pitfall — a "dormant/empty" inbox may be a live send-From address

Before deleting any inbox, check its messages AND their direction. A mailbox with
few/no RECEIVED messages can still be an active **send-From** identity: outbound
messages carry `labels:["sent"]` and `from` = the inbox itself. `avi_brief@
agentmail.to` looked dormant (3 messages) but was the designated daily-brief
send-From address — a manual brief email went FROM it TO Avi's Gmail on 8/15.
Deleting it would have silently broken that pathway.

Audit before deleting:
```
GET /inboxes/{inbox}/messages?limit=50      # inspect labels + from + to
GET /inboxes/{inbox}/messages/{message_id}  # full message (preview truncates)
```
- `labels:["sent"]` + `from` = the inbox → it is a **send-From identity**, not
  just a receive box; deleting it breaks whatever sends FROM it.
- The org's 3 inboxes are the shared free-plan resource. Recreating a freed slot
  can't be pre-verified at the cap (a 4th create only confirms the cap), so safe
  order: confirm the in-use inbox is nonessential → preserve messages if desired →
  delete → immediately create the replacement.

## Live inbox inventory (8/15, UPDATED 8/15 late)
- `coordination@agentmail.to` — Hollow↔Alyosha lane (Hollow reads/sends here)
- `system-alerts@agentmail.to` — agent-originated mail; agents send FROM this
- `avi_brief@agentmail.to` — **DELETED 8/15** (was daily-brief send-From → Avi's Gmail; brief email now sent FROM `system-alerts@` instead, no capability lost — files preserved in vault `Calendar/Daily Briefs/`).
- `clumsyclass314@agentmail.to` — **Mayumi's inbox** (display name `mayumi-ilocos`), created 8/15. Scoped key `mayumi-ilocos-agent` on VPS1 `.env` + send allowlist (avipenhollow@gmail.com, kathleano@yahoo.com, coordination@, system-alerts@).

## Concrete API mechanics (verified 8/15) — exact paths & pitfalls

REST base `https://api.agentmail.to/v0`. Auth `Authorization: Bearer $AGENTMAIL_API_KEY` (org key for admin ops).

**Create a scoped inbox key** — NOTE the hyphen:
```
POST /inboxes/{inbox_id}/api-keys        # NOT /api_keys (that 404s)
{"name":"mayumi-ilocos-agent","permissions":{<whitelist booleans>}}
```
Whitelist = only `true` perms granted; omitted/false denied. For an internal agent: `message_read/message_send/message_update/draft_read/draft_create/draft_update` true; leave `message_delete/draft_send/api_key_*/list_*/domain_*/webhook_*/inbox_*` false. Set `label_spam_read/blocked/unauthenticated/trash_read` false to hide junk.

**PITFALL — the full key is shown only ONCE at creation.** The response includes the complete `api_key` value exactly once; you cannot retrieve it again (only the id/prefix are listed later). If you truncate or redact the creation response before capturing the key, you MUST delete that key and recreate it to get the value back. Capture the key in the same command that creates it and write it straight to the target's `.env` — never rely on re-reading it later. Verify remotely with a masked grep.

**Inbox creation auto-assigns a random address — the requested address is IGNORED and NOT editable.**
```
POST /inboxes  {"email":"mayumi-ilocos@agentmail.to","display_name":"mayumi-ilocos"}
```
returns an auto-generated address (e.g. `clumsyclass314@agentmail.to`); the `email` field you send is silently dropped. PATCH cannot rename the address either (only `display_name`/`metadata` are editable; the address stays random). This is acceptable for internal-only use — the display_name carries identity. Don't fight it; tell Avi the real address so he knows which is Mayumi.

**Send allowlist (inbox-level) — the external-send gate:**
```
POST /inboxes/{inbox_id}/lists/send/allow   {"entry":"avipenhollow@gmail.com"}
GET  /inboxes/{inbox_id}/lists/send/allow   # verify: response.entries
```
Add every internal address you want the agent to reach autonomously. Anything not allowlisted cannot be sent by that key (draft-only). Inbox-level lists override pod/org.

**Negative-test a scoped key before trusting it:** with the scoped key, `GET /inboxes/{inbox_id}/messages` succeeds (count 0 on fresh inbox) while `DELETE .../messages/{id}` returns `403 {"code":"missing_permission", ...}`. Proves read works and delete is truly denied.

**Wiring AgentMail MCP into a Hermes profile (Mayumi 8/15 — set up, restart still pending):** install the `mcp` package into the profile venv (`pip install --upgrade mcp`; Hermes's `mcp_tool.py` imports `mcp.client.streamable_http.streamable_http_client`, which mcp≥2.0.0 provides), then
`hermes --profile ilocos config set mcp_servers.agentmail.url "https://mcp.agentmail.to/mcp"` and
`hermes --profile ilocos config set mcp_servers.agentmail.headers.Authorization "Bearer \${env:AGENTMAIL_API_KEY}"`.
Config reads at gateway startup — the change is inert until the gateway restarts (see the gateway-restart guard in SKILL.md; the no_agent-cron workaround can itself be blocked, so the restart may need Avi to run `systemctl restart hermes-gateway-ilocos` from outside).
