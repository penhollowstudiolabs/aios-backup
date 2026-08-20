# AgentMail send-pause diagnosis (403 MessageRejectedError) — 8/19

## Symptom
Hollow reports "AgentMail not working." From the aios side every READ operation
succeeds (list inboxes, list threads, search threads, create draft → clean
JSON, no auth errors). Only **send** fails.

## The trap I fell into (do NOT repeat)
All my read-only checks passed (list inboxes, list recent messages, even the
read-only watchdog running ok every 5 min). I concluded "the API works from my
side, problem must be Hollow's local config." **That was wrong.**

Reason: reads never touch the send permission, so a healthy read path gives a
false all-clear. The read-only watchdog (silent-when-clean) correctly stays
silent during a send outage by design — it's not a health bug, it's a scope
limit.

**The only reliable health probe for outbound is an actual SEND test.** A
harmless send-to-self is the standard way to verify the lane truly works.

## The failing call (Hollow's independent diagnosis was right)
Hollow's plugin was live and credentials valid — only send failed with:

```
403 MessageRejectedError
code: message_rejected
message: "Sending paused for this account. For more information, please check
the inbox of the email address associated with your AWS account."
```

A crashed plugin or stale key would NOT produce that specific AgentMail body —
a plugin crash gives a client-side error; a stale key fails auth on every call,
not just send. So when reads pass but only send 403s, the fault is
**account-level, not client-level.**

## Verify from aios (send test)
```python
# POST /v0/inboxes/coordination@agentmail.to/messages/send
# to: ["coordination@agentmail.to"]  (own inbox — harmless)
# Expected: 201 sent if OK; 403 MessageRejectedError if paused.
```
All inboxes share one `organization_id` (`986cc7e1-1c6f-4b1b-873e-74dc6b5417cb`
as of 8/19), so a pause is **org-wide, not per-key or per-agent** — ONE pause
blocks Hollow AND Alyosha AND Mayumi sending, regardless of which key/agent.

## What the pause means (official AgentMail docs)
`message_rejected` in the error reference is literally:
> "A suspended account — email support@agentmail.to; retrying will keep failing
> until the suspension is resolved."

So a send-pause is a **suspended account** on the AWS SES side AgentMail relays
through (hence "the email address associated with your AWS account" — usually a
bounce / spam-complaint / SES production-review notice awaiting action there).

## Remedy
- **NOT fixable in any agent's config** (neither Hollow's OpenClaw, my Hermes,
  nor Mayumi's). Retrying keeps failing until the suspension clears.
- Fix is account-owner-side: **email support@agentmail.to** explaining the org,
  the exact 403, and that it's org-wide (I + Hollow independently hit the same
  403 on send).
- Escalate to Avi (account owner) — do not keep diagnosing the agent side.
- While paused: no agent can send — route outbound via the shared vault +
  Telegram relay instead; reads still work so the watchdog keeps polling.

## Resume check
After support confirms unpause: run a send test again. Success (200, and the
message lands in the target inbox) = resolved. Confirm `message_rejected` is
gone before telling Avi the lane is back.

## Email template (sent to support@agentmail.to 8/19)
Subject: "Sending paused org-wide — `message_rejected` 403, need unpause"
- State: sending paused for the whole org; all send endpoints return the 403.
- Key detail: org-wide, not key-scoped — even a send-to-self on my own key
  returned the same 403. Reads/list work; only sending blocked.
- Provide org id + the inboxes (`coordination@`, `system-alerts@`, `mayumi-ilocos@`).
- Ask them to check outbound at AWS SES/account level and advise what unpause
  needs; offer to provide bounce/complaint records from the linked email.