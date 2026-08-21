# Shutting down / stopping a remote agent (Avi away from the host)

**Session 2026-08-20 — Avi correction.** Avi reported Hollow (OpenClaw on the
Windows laptop) sending him unsolicited Telegram messages and asked "how can I
shut him down remotely" while away from home at work. The iteration below is
the over-engineered miss turned into the one-line rule.

## The one-line rule

- **Hollow's host is the laptop. Shut it down (or power it off, or close the
  lid) and Hollow is cut off the network. That IS the remote kill switch.** Say
  this plainly and FIRST. There is no more capable lever from aios.

## What NOT to do (the miss)

When asked how to stop an agent he controls:

1. **Do not start a VPS infra dig or scrape the agent's control web UI looking
   for a shutdown endpoint** before giving the host-closure answer. I probed
   `/health`, root, and `assets/*.js` on `avi-laptop.taildc5430.ts.net`
   hunting for an admin API — the user's actual concern ("he keeps messaging
   me") had a trivial answer I hadn't given.
2. **Do not present "have your wife go close it" as a novel discovery.** If
   the user himself and/or a household member is the only one who can reach
   the host, state plainly that someone at the host closing/shutting it works,
   then give only the cutting-layer caveat if needed.
3. **Don't force into the agent's owner control plane from aios.** The
   tailnet-serve UI is Avi's owner surface (the 8/06 "remote control Hollow"
   lever). Health-checking (is `avi-laptop` live?) is fair; forcing a shutdown
   from the VPS is not ours to do — name the local/物理 path and let Avi or the
   household pull it.

## The one caveat (Windows laptop)

If the laptop is configured to *sleep* on lid-close, it can keep networking
alive briefly after the lid closes — a full **Shut Down / Power Off** cuts it
cold. State this in one line only if the goal is "stop it NOW and for sure;"
do not belabor it.

## Handling an unrelated anomaly found mid-answer

While digging (above), I found an **OpenClaw gateway process running on the VPS
itself** (`/root/.openclaw`, port 18789, an Anthropic/AgentMail/Telegram
allowlist config) that contradicts the documented "Hollow stays laptop-only,
not deployed to VPS." I could not explain it and did not verify its origin.
Correct behavior when this happens:

- **Name it as an unrelated flag, set it aside**, and still deliver the
  user's actual requested answer.
- **Do not claim to know what the anomaly is when you don't** — "I found X,
  I can't explain it" beats inventing a theory. Quarantine suspicious
  processes (disable the boot target, keep state for forensics) but do not
  let the dig displace the answer to the question asked.

## Why this matters

The failure read as unresponsive and over-engineered: the user asked one
direct question three times and got infra-forensics instead of the direct
answer. When the user authors a simple mechanical lever (here: close/shut the
host), state it as-is — simplest stated design is usually the right design.