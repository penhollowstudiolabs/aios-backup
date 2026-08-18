# macOS Hermes desktop onboarding (fresh Mac install)

Scenario: installing Hermes Agent on a NEW Mac (daughter's MacBook, teen, new to
agents but knows LLMs). Class-level recipe proven 8/16. Applies to any fresh
macOS box, not just the daughter.

## The one thing that dominates a fresh-Mac install: HIDDEN DIALOGS

macOS first-run of any dev stack silently queues background permission /
download dialogs **behind the main window**. Result: the installer "crawls" or
"hangs" at a step that is actually waiting on a click you can't see. This bit
us twice in one install:

- **Xcode Command Line Tools** — a first dev-tool run triggers a large CLT
  download/install. It sat behind the Hermes window as a nearly-invisible
  "Installing Command Line Tools" / "Terminal wants to make changes" dialog.
  The progress bar crawled while macOS waited for the click.
- **"Install browser tool dependencies"** — almost certainly the Playwright /
  Chromium engine download (~150MB+). Same pattern.

**Diagnostic before assuming a hang:**
1. Check for a second permission/installer dialog behind the main window
   (menubar bounce, dock bounce, window behind). If present → click OK/Install;
   that IS the bottleneck. This was the cause BOTH times.
2. Activity Monitor → Network tab: real throughput = legitimately downloading,
   let it finish; idle AND no dialog = genuinely stuck → retry.

**Don't let the user restart on the first stall** — check the hidden dialog first
(it was the cause twice in a row). First-launch of any dev stack on a fresh Mac
is slow; later launches are instant.

## Deploy order that worked (girl's Mac, 8/16)

1. **Bitwarden FIRST** — before any key touches the machine. Free personal plan.
   - Create account (strong master password + save recovery sheet out-of-band).
   - **Store an API key as a Secure Note** (NOT Login for site creds, NOT
     Identity which is for personal info forms). Put the actual key in a
     **Hidden field** (Add Field → Hidden) + context in the note body.
   - Habit: key → Bitwarden → then paste where needed. Never in Notes/files.
2. **OpenRouter account + key** (her own, not shared):
   - openrouter.ai → sign up → Keys → Create Key → copy `sk-or-v1-…`
     (shown once). Save to Bitwarden immediately.
   - Note: OpenRouter generally needs a small deposit (~$10) before free-tier
     keys work for all models; the key still completes Hermes setup.
3. **Install Hermes** — `curl -fsSL https://hermes-agent.nousresearch.com/install.sh
   | bash`, OR download the official macOS `.dmg` (Hermes-Setup.dmg) from
   hermes-agent.nousresearch.com and **drag the app into Applications** — the
   .dmg desktop-installer path is more beginner-friendly than Terminal. This is
   the desktop app = native Electron surface. Beware the hidden CLT/browser-deps
   dialogs above.
4. **Launch + setup** — pick **OpenRouter** as provider, paste the key from
   Bitwarden, create a named profile (isolated config/skills/memory). For a
   learning user set the model to **DeepSeek flash** (`deepseek-v4-flash-0731`),
   not frontier — cheap while learning.
5. **First messages** — small talk first (proves the key works + least
   intimidating), then ONE small real task to feel "agent not chatbot."
6. **Obsidian + learning directory** (optional next step) — a small "Hermes Lab"
   folder: `01-Project/ 02-Learning/ 03-Captures/ README.md`, with Hermes
   reading/writing the same folder the vault opens.

## Model switching after setup (if defaulted to something else)

```bash
hermes config set model.provider openrouter
hermes config set model.default deepseek/deepseek-v4-flash-0731
hermes model --set deepseek/deepseek-v4-flash-0731   # verify
```
Then **quit + reopen the desktop app** for the config to take. Or use the app's
model picker (⌘/Ctrl+K or settings). Don't assume the default the wizard picked
is what Avi wants — ask.

## School-provided LLM accounts — the boundary (Avi decision, 8/16)

Daughter's school offers ChatGPT. Do NOT build her personal agent stack on a
school account:
- EDU accounts are admin-managed (district sees usage, applies filters/controls,
  can terminate) — exactly what a district AUP flags, and a personal-agent
  backend on a school account is a liability for Avi (employee AND parent).
- Treat the school account as a school resource for school work, fully separate
  from her personal agent setup.
- If "she'll pay for one proprietary model," the clean path is her OWN
  ChatGPT/Codex subscription (~$20/mo) — her OAuth, her accountability — not the
  school account. OpenRouter now, her own proprietary sub later when OpenRouter's
  limits pinch.

## So the clean line
- **OpenRouter now** (learning, cheap)
- **her own proprietary sub later** (when she wants Codex/top-tier)
- **school account = school work only**, never a personal-agent backend.
Use this three-way boundary in any onboarding notes so it's explicit.

## Connecting the new Mac to Telegram (8/16) — the gateway attach

After Obsidian/learning-dir, the next step is giving the agent a phone path via a
Telegram bot. The attach frequently fought us; here's what actually worked.

1. **Create the bot (on the phone):** Telegram → @BotFather → `/newbot` → name +
   a username ending in `bot` → save the returned BOT TOKEN to Bitwarden (Secure
   Note) immediately.
2. **Attach it to the gateway.** This is where the CLI verbs are NOT what they
   look like — **do not guess them** (I sent `hermes gateway setup --platform
   telegram`, which errors: `gateway setup` is not a real verb; `--platform` is
   not a flag). The two correct entry points:
   - **`hermes setup gateway`** — the interactive messaging-platform wizard
     (toggle platforms with Space, confirm with Enter). BUT it can print
     \"No platforms selected\" and skip straight to \"configuration complete\"
     without ever asking for the token — terminal key-input on the selection
     window is famously finicky and can be silently non-interactive.
   - **`hermes dashboard`** — the browser admin UI is the RELIABLE path when the
     terminal wizard stalls. It opens a local web page with a
     **messaging/channels** section where Telegram + paste-token is a normal
     click, no arrow-key dance. This is what finally worked.
3. **Restart the gateway to apply** — a platform added after the gateway service
   is already running (launchd) isn't picked up live: `hermes gateway restart`.
4. **Phone test = the only pass criterion:** open the bot on the phone, send
   `hi`, get a reply. Until that works it's not wired.
5. **Bot is private to her:** the gateway needs the Mac's Terminal/session
   running (closing it kills phone replies until it's back) — tell the user
   that up front so a later \"it's silent\" isn't a surprise.

Lesson to carry: `hermes dashboard` is the friendliest UX path for platform
attach and sidesteps both the bad-CLI-verb trap and the flaky selection window.
Prefer it over guessing terminal flags.
