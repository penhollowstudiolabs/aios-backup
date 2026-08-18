---
name: hermes-macos-desktop-install
description: "Mac Hermes install (Tati). Use when onboarding."
version: 1.0.0
author: Alyosha
license: MIT
platforms: [macos]
metadata:
  hermes:
    tags: [hermes, install, macos, onboarding, bitwarden, obsidian]
---

# Hermes Desktop Install — fresh Mac (Tati's laptop)

Onboarding a newcomer (teen, knows LLMs but new to agents) onto the Hermes
desktop app on a MacBook, scoped to *their own* private setup (not Avi's AIOS).

## Flow (in the order discovered to work)

1. **Download** from hermes-agent.nousresearch.com → Mac OS → `Hermes-Setup.dmg`
   (official; domain matches hermes-agent skill). Drag app into Applications.
2. **Bitwarden FIRST** (before any API key exists). Free personal tier.
   - Critical item-type rule: an **API key goes in a Secure Note** (with the key
     in a **Hidden field**), NOT an Identity and NOT a Login. Identities are for
     personal-info auto-fill, not secrets.
   - Habit to set: every key → Bitwarden Secure Note → then paste where needed.
3. **OpenRouter account + key** (her OWN key, not shared). Create key, save into
   the Bitwarden secure note immediately. Note: OpenRouter needs a ~$10 min
   deposit before free-tier keys work for model calls.
4. **Hermes setup**: provider=OpenRouter, paste key from Bitwarden, profile=her
   name. Pick **DeepSeek** (cheap) for learning, not frontier.
5. **Connect Obsidian** later (she uses LYT Kit) — Hermes writes into the same
   folder the vault opens.

## Pitfalls (macOS first-run — the real blockers)

- **Hidden macOS install dialogs.** "Crawling/hung" steps are usually a
  *background* window waiting for a click, not a stalled download. Check for the
  second dialog before restarting anything. We hit this TWICE: Xcode Command
  Line Tools, then browser-tool deps (Playwright/Chromium ~150MB download).
- **Browser-tool deps are optional for chatting** (needed only for the agent's
  web/browser tools) — don't block a first message on them.
- **Model switch later:** `hermes config set model.provider openrouter` +
  `hermes config set model.default deepseek/deepseek-v4-flash-0731`, then quit &
  reopen the desktop app (it doesn't hot-apply). Or use the app's model picker.

## Boundaries (Avi's explicit preferences)

- **Student's school ChatGPT account = school work ONLY.** Do NOT hook it into a
  personal agent stack (institutional account = district-admin visibility, AUP
  liability). Personal LLM work uses her OWN OpenRouter now → her own paid
  proprietary sub later (~$20/mo). Three-way line: school-account=/=personal.
- Avi is ~15 yrs off macOS — keep it one turtle step at a time, exact clicks,
  no assumed Mac fluency.

## End-shape target
A simple "Hermes Lab" directory (01-Project / 02-Learning / 03-Captures +
README) she owns, which Hermes writes into through Obsidian — showing how Hermes
helps with her apps, not Avi's AIOS complexity.