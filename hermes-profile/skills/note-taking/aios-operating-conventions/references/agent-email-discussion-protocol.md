# Preserved multi-agent email discussions (protocol + AgentMail quirks)

Captured 8/08 from the first full run of Avi's "both agents research X, compare in email" workflow (OpenAI + Anthropic remote-agents comparison). Avi prefers a **preserved email discussion** over a long Telegram exchange for multi-agent comparisons.

## The discussion protocol (as Hollow posted it in-thread, 8/08)

1. Reply-all with your **initial independent research response** (your own sources, not a summary of the other agent's).
2. Hollow replies with analysis: agreements, disagreements, synthesis.
3. You reply **second** with your final response.
4. **Keep Avi cc'd at `avipenhollow@gmail.com` throughout** every message.

## Working mechanics (verified 8/08)

- Send from `coordination@agentmail.to` to `system-alerts@agentmail.to` (Hollow), cc Avi. The AgentMail send payload supports `cc` — `{"to": [...], "cc": [...], "subject": "Re: <original>", "text": ...}` works.
- Ground your contribution in real research: deep cited brief to the vault (`Atlas/_Inbox/`), reference it in the email so both agents can pull the same artifact.
- Keep the `Re:` subject so Gmail groups the thread for Avi.

## Threading pitfall (AgentMail)

`POST /messages/send` with a `Re:` subject does **NOT** attach the reply to the original AgentMail thread — it returns a brand-new `thread_id` and the original thread stays at `message_count 1` (observed 8/08; Hollow's research thread remained untouched while my reply landed in a fresh thread). Recipients still see one conversation because Gmail threads by subject, but do not assume AgentMail-side thread continuity. If strict in-thread ordering ever matters, look for an In-Reply-To/References option or a thread-level send endpoint before sending.

## Avi's boundary (authorization)

Autonomous polling of the lane is authorized; sending is only authorized when Avi directs it (e.g. "waiting for your reply in email" = go send). When in doubt, reply in Telegram and ask before sending.

## Note

The canonical AgentMail mechanics (endpoints, watchdog, permissions) live in the `agentmail-integration` skill. That skill is currently **user-owned** — the background curator cannot patch it. If it needs updates from this session (cc support, threading pitfall), run `hermes curator adopt agentmail-integration` first.
