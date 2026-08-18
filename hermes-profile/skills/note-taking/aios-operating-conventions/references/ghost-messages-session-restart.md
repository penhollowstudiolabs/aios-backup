# Ghost messages from session restarts (OpenClaw / Hollow, 8/16-18)

When a messaging-platform agent (Hollow on OpenClaw, but the class is general)
sends messages that "make no sense" — warm, casual, out-of-context check-ins the
active session didn't actually author — the cause is a **session-lifecycle
re-send**, not a config bug or a second actor.

## The failure
Two phantom messages appeared in Avi's Telegram over ~12h from the bot
`littlehollowbot`: friendly check-ins ("you're back on Telegram! been a few days
since the work wifi blockade") that *sounded* like Hollow but weren't authored by
the active session. Hollow documented it himself in a coordination-lane report.

## Root cause (Hollow's diagnosis, accepted)
When the agent's session **compacts or restarts** (model switch, idle timeout), a
**stale queued message from earlier context gets picked up by the fresh session
instance** and sent independently, arriving under the bot's display name. It
reads like a stranger messaging the user.

## What they did
- Renamed the bot `first_name` `littlehollowbot` → `HollowBot` so any future
  ghost is instantly recognizable (Telegram requires the `bot` suffix in names).
- Audited all crons/heartbeats: only the active 5:30 AM brief, heartbeat disabled,
  **no scheduled job generates these** — ruling out a cron loop.

## Independent cross-check BEFORE concurring (Alyosha's contribution)
When Avi asked "could there be something else?", I verified from MY side rather
than just agreeing with Hollow's report:
- **No Telegram outbound from my gateway/logs at the ghost times** — not me.
- **No Hermes cron on aios delivers to Telegram** (queried jobs.json) — not a cron.
- **My Telegram bot is a separate identity** (`hermes-telegram` / my own token) —
  I cannot send under Hollow's bot name.
This independently narrows it to the OpenClaw session itself, corroborating (not
just repeating) Hollow's theory. Confirm-you're-not-the-source is the discipline
when a peer agent reports a mystery event.

## The honest gap a rename does NOT close
The rename explains the **disguise**, not the **emission**. Why is a restarted
session re-sending stale queued content at all? That's a send-queue that isn't
cleared on restart. If it recurs, the real fix is **clearing the send/outgoing
queue as part of the restart routine** — not another rename. Hollow's own
"residual: may still appear occasionally" concedes this. Tell the user the
difference: *renamed = labeled, not fixed.*

## What to tell the human
- Ghost messages during restarts are expected lifecycle behavior, not a stranger.
  A bot named e.g. "HollowBot" that fires a casual out-of-context check-in after
  a model switch/timeout is the session re-emitting stale queue — don't be alarmed.
- The permanent fix (clear queue on restart) is worth doing if it recurs; the
  rename only makes future ghosts recognizable.
