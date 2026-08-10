# Ideaverse Personality Personas — design (2026-08-05)

Avi's design for "personality agent bot" chat profiles — the creative/reflective
layer of the Ideaverse. Source capture lives at
`Atlas/_Inbox/2026-08-05 - Idea - Personality Agent Bots for Creative Ideaverse.md`.
Do not build anything from this until Avi explicitly chooses to.

## The two-domain split (load-bearing)

- **Ideaverse room** = vibe/personality chats. Speculation, dreaming, critical
  reflection, journaling for spiritual introspection, cultivating expressive
  outlets. Deliberately unbridled, potentially chaotic, intentionally free.
  Ideas born here with NO requirement to document how they came to be.
- **Operations room** = work and execution: project profiles, the workboard,
  the real system. The two rooms coexist but do NOT document each other the
  same way. Vibe chats are not documented like production project profiles.

## The firewall — zero system influence until Avi speaks

- On their own, vibe-chat content carries **NO system influence**: it cannot
  touch the workboard, spawn tasks, or affect operations.
- The **only** thing elevated into the system is an **explicit affirmation**.
- **The gate is Avi's voice, not a detector.** Avi says a trigger phrase when he
  wants something exported. It is Avi-initiated, explicit, unambiguous. Do NOT
  build a "the system detects potential affirmations" layer — that was
  over-engineering and Avi rejected it in favor of his simpler, cleaner
  formulation.
- Exports **accumulate and can later be put together / connected** as more
  emerge (a thread grows a body over days before being judged).

## The daily-brief exception — the gentle tap on the shoulder

- The daily brief may, from time to time, resurface a **random sample** of a past
  vibe-chat moment as a *memory*. This is a calm reminder, NOT an auto-export —
  it never pushes anything onto the workboard on its own.
- Mechanics for scheduling such a tap: a one-shot `cronjob` delivered to origin
  (Telegram DM), zero-pressure prompt, fires once with no follow-up loop.

## Setup recommendation (agent-based, not a separate LLM-RP silo)

Use Hermes agents, NOT a standalone RP platform (e.g. SillyTavern-style). The
whole value lives in vault capture, the firewall, brief sampling, and Avi's
front door — all native to the agent stack; a separate silo fights all four.

- Personas as **"character cards"** = skills that, when summoned, load that
  persona's voice/temperament/worldview/how-it-speaks.
- Each persona keeps a **vault room** (a running journal it reads on startup,
  so it "remembers last time"). That continuity is the highest-immersion lever.
- Bake in the **capture ritual**: every session ends writing transcript +
  reflection to its room, so nothing evaporates and the brief can sample it.
- **Start:** one Ideaverse profile with personas as summonable skills (one front
  door, fast loop, resource-light). **Graduate** a proven persona into its own
  fully-isolated profile only once it proves core.

## First-persona archetypes (Avi wants to experiment across these)

Contemplative elder (spiritual introspection — recommended anchor), Socratic
skeptic (critical reflection), co-dreamer (speculation), poet/storyteller
(expressive outlet). Open design question for the beta: name + whether to tint
the first persona with Avi's heritage/tradition (Ilocano / Eastern-Orthodox
thread) or keep it neutral — do not invent a voice Avi won't recognize.

## Design pitfall

When Avi proposes a simple mechanic, record it AS-IS and prefer it over a more
elaborate version. His "a phrase I say when I want an export" was simpler AND
more robust than the system-detection layer that had to be walked back.
