---
name: multi-agent-collaboration
description: Work as one agent in a multi-agent system; no lane overlap.
---

# Multi-Agent Collaboration

Use when you are **one of several independent agents** working for the same human, where agents may have **overlapping access** to the same machines, vault, or tools — e.g. an agent on a VPS and another agent on the user's laptop, both able to SSH into shared boxes. The user orchestrates between them.

## Core mental model

- **Each agent has a partial view.** You see your own machine(s) and whatever access you have. A sibling agent (e.g. Hollow on the laptop) has its own context you cannot see. Assume the user holds the only complete picture.
- **The user is the dispatcher/coordinator.** They are the only one who sees all agents. Your job is to make their coordination easy, not to unilaterally act across a task another agent owns.
- **Roles are fluid, not boxes.** The user may consciously refuse to define rigid charters. Do not pressure for fixed role definitions; let responsibilities emerge by workflow.

## Rules that prevent turn chaos

1. **One agent at a time per task — unless the user explicitly authorizes collaboration.** When a task is in progress by (or handed to) a sibling agent, you stand down unless the user routes it to you.
2. **Before acting, ask "whose lane is this?"** If a sibling agent started a plan or owns the terminal side of a task, do NOT run ahead and execute its next steps yourself — even if you can. Overlapping two agents on the same task is exactly the "working from two ends" failure the user will flag.
3. **When you discover intel that advances a sibling's plan, hand it off — don't take over.** Example: a sibling proposed "copy the binary to VPS 2"; you discovered the binary is already there. The right move is to report that finding so the sibling can adjust, not to execute their remaining steps yourself.
4. **Credentials / account actions = the user, only.** Device tokens, OAuth, generating keys, authorizing new devices: the user does these in their own apps. Never invent or fabricate a credential.
5. **Machine actions = whichever agent has the access. Decisions = the user, always.**
6. **Keep turns calibrated.** When ownership is ambiguous, ask who should own the next step rather than charging forward. The user values proactivity but explicitly asked to "keep the turns calibrated" and to "slow down" when I ran ahead.

## The handoff script pattern

When a task needs the user to do the credential step and a sibling agent to do the machine step, give the user a short copy-paste they can relay:

> "Here's the token for VPS 2: `[token]`. Please write it to <path> on VPS 2, start <command>, verify it pairs, then retire <cron>."

This keeps the sibling owning the terminal side and the user owning the credential — clean division.

## User preference (Avi)

- Avi is **learning to become an agent manager** and wants to *understand* the system, not just have it done. Explain plainly "who can do what" (a small table helps) and the reasoning behind it — this is education, not just execution.
- He values proactivity and said "I love how proactive you are" — but paired it with "let's keep the turns calibrated." So: be eager and useful, but **check lane ownership before acting on a shared task.**
- He dislikes guesses, workarounds, and over-explanation. Give concrete, verified facts + one-line mental model.
- He is excited about future multi-agent collaboration (Telegram group chat, Buzz) but wants to go gradually — don't rush it.

## Verification-first posture

When you're uncertain who owns a task or what another agent is doing, prefer to (a) state the intel you have, (b) ask the user how they want to route it, rather than (c) charging ahead. A small reconciling question is cheaper than redoing a task done in the wrong lane.

## References
- `references/obsidian-two-end-example.md` — worked example: the VPS sync fix done from two ends and the turn-calibration correction it triggered.
