# Datacenter-IP-blocked services — residential egress only

Avi's VPSes (aios, ilocos) are datacenter IPs. A growing set of consumer/retail
services refuse requests from cloud-provider IPs. This is a recurring class of
failure, not a one-off — expect it for any new consumer-platform integration.

## Known-blocked (verified)

| Service | Symptom | Workaround used |
|---|---|---|
| Amazon / retail | research blocks, listing tooling | residential egress (Avi's note: "Amazon/retail block VPS datacenter IPs; use residential egress for research") |
| YouTube transcript API | `youtube-transcript-api` returns "YouTube is blocking requests from your IP … IP belonging to a cloud provider" | **Option A (durable, works from VPS):** third-party transcript API (free-tier, e.g. youtube-transcript.io 25/mo) — runs its own infra, not cloud-blocked. **Option B (existing):** Hollow on the laptop (residential IP) fetches and drops it in the AgentMail lane / vault. Tested 8/11: `yt-dlp` also bot-blocked on VPS; Invidious/Piped public instances largely collapsed. |

## YouTube transcript setup (verified WORKING 8/11 — youtube-transcript.io API)

**This is now the primary path from the VPS — no residential egress needed.**

- **API:** `youtube-transcript.io`, free tier 25 transcripts/mo. Key stored in profile `.env` as `YOUTUBE_TRANSCRIPT_API_KEY` (NOT in the vault). Avi keeps a copy in Bitwarden under "YouTube Transcript API — Alyosha/Hermes".
- **Helper:** `~/.hermes/profiles/alyosha/scripts/fetch_youtube_transcript.py` — takes a YouTube URL or 11-char ID, returns JSON segments (`{text,start,dur}`). Read the `Notes` header in the script for the two gotchas.
- **Pitfall A — auth header:** endpoint is `POST /api/transcripts`, `Authorization: Basic <token>` (NOT Bearer), body `{"ids": ["<video_id>"]}` (array, NOT `video_id`).
- **Pitfall B — User-Agent:** the API 403s on urllib's default UA; must send a browser `User-Agent` header. This is why a plain urllib call failed while curl worked.
- **No language selection on free tier:** the `language` param is ignored; you get the video's DEFAULT caption track (which may be auto-generated/non-English). If Avi needs English specifically, the practical path is still the `youtube-transcript-api` library via Hollow (residential) which supports language fallback — or accept the default track and flag the language.
- **Legacy (`youtube-transcript-api` lib, 8/10):** still blocked from the VPS datacenter IP; only usable via Hollow (residential). `fetch_transcript.py` in the `youtube-content` skill uses this lib. Keep as fallback, not primary.
- The old venv-interpreter + terminal-guard-null-byte pitfalls apply only to the legacy lib path, not the new API helper.

## Third-party transcript API = the verified durable route from the VPS (8/11)

When Avi asks "make me able to read YouTube videos I drop in" (rather than
route through Hollow), prefer a **third-party transcript API** — it runs its own
infrastructure, so its IPs are not cloud-blocked the way aios is. Verified live
8/11: direct VPS routes are ALL dead (details in the table above), and this is
the one route that works from the datacenter IP.

- **youtube-transcript.io** — free plan 25 transcripts/month; Plus $9.99/mo
  (1000/mo). API needs an account + API key (probe returned
  `Unauthorized, no token provided` until keyed). Store the key in the profile
  env, never in the vault.
- Also seen with free tiers: Supadata (~100/mo), TranscriptAPI, SocialKit,
  EasyTranscriber.

**Decision nuance vs the general rule below:** the general "let Hollow fetch"
rule holds when the laptop is the natural egress. But when Avi wants Alyosha
INDEPENDENT of the laptop/Hollow, the free-tier transcript API is the costless
way to get that independence (no residential proxy spend). 25 free/mo covers
Avi's "things I'm interested in" link-capture rate comfortably.

**Pitfall — link+notes capture needs NO egress at all.** Even with no working
transcript path, Alyosha can always file the link + Avi's attached notes to
`Atlas/` immediately. Transcript is the enhancement that makes a saved link
readable, not a prerequisite for capture.

**Edge case — captions disabled.** Some videos return nothing from a transcript
API. Fallback is audio → local faster-whisper, but that burns compute; treat as
edge case, not default.

## Decision rule for Avi

Do NOT burn money/infra on proxying from the VPS when the laptop already has a
residential IP and Hollow lives there. Default division: Hollow fetches, Alyosha
processes into summaries/chapters/blog. Match this to the existing
"one working lead per task / Hollow = laptop-local evidence" convention.
