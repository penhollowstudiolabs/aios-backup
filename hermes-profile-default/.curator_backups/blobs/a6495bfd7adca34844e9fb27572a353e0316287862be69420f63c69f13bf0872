# Coordination-lane verification (live source before conclusions)

Class of task: a coordination-lane message — typically an AgentMail watchdog relay into Telegram — surfaces and a human asks "why is this being flagged now?" (or "is this old or new?").

## Failure mode observed (2026-08-25)

A user asked why a crash-loop/telegram incident was being flagged that day. The agent answered "nothing is flagging it now" based on session-history search alone, without reading the live AgentMail inbox. That was wrong: the mail was fresh (same-day timestamps), describing a live VPS1 gateway outage that had been running since the prior Sunday. The agent had to correct itself.

Two distinct mistakes:
1. Classified the alert as a stale replay without confirming against the live inbox.
2. Assumed the current profile had done the coordination-lane work just because the message came FROM the shared `coordination@` address.

## Durable rules

1. **Verify against the LIVE source before characterizing an alert as stale/new.** For AgentMail, call the inbox message list and read timestamps, sender, labels, and message bodies. Session history (session_search) is NOT authoritative for live mail — a fresh incident can exist with no session record in the current profile, because the doing-work session lived on another machine/agent/path or was never captured.
2. **Do not assume authorship of shared-lane outbound mail from your own session history.** Mail FROM `coordination@agentmail.to` can originate from Hollow, another agent, or another path. If a message claims systemd/credential/egress changes, treat authorship as unverified until traced.
3. **Respect documented boundaries while tracing.** If the claimed change touches a "remediate only with Avi present" boundary (e.g. VPS1 default-service crash-loop remediation was explicitly deferred as Avi-present-only in the 7/31 and 8/22 handoffs), flag the potential boundary crossing rather than silently accepting or disclaiming it.
4. **Report the gap honestly.** State which part is verified (live inbox shows the mail is fresh) vs. which is unverified (who did the work, whether a boundary was crossed). Offer to trace or document; don't fabricate authorship.
