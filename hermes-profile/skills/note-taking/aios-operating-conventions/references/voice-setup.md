# Voice setup for Avi's profile (TTS/STT) — captured 8/09

State as of 8/09: voice is ON for Avi's profile and works without any setup on
his machines.

## The persistent switch vs the CLI toggles

- **Persistent:** `voice.auto_tts` config key (set `hermes config set
  voice.auto_tts true`). When true, the gateway auto-sends a TTS voice reply
  for responses. This is the "set it and forget it" switch.
- **CLI/session toggles:** `/voice on` (voice-to-voice), `/voice tts` (always
  voice), `/voice off`, `/voice status`. These are session-scoped in the CLI —
  the slash commands in chat are NOT the persistent config. When Avi types
  `/voice tts` in chat and it doesn't stick, the fix is the config key.

## Config change timing caveat

Config changes (including `voice.auto_tts`) sync into the gateway **at
gateway startup** — they may not take effect mid-conversation. Either restart
the gateway (brief interruption, ~30s) or let it pick up on the next natural
restart. Tell Avi this honestly rather than promising instant effect.

## STT is server-side — Avi never installs whisper

STT = local faster-whisper (already installed on the VPS, `faster_whisper`
1.2.1). Telegram voice notes are transcribed on the server. Avi's machine
(phone/laptop) only needs the mic button in Telegram; he does NOT need whisper
or any STT package locally.

## TTS providers (free default)

- Default `tts.provider` = `edge` (free, Edge neural voices, e.g.
  en-US-AriaNeural). No API key.
- Others available: elevenlabs, openai, xai, minimax, mistral, gemini,
  deepinfra, neutts, kittentts, piper (local).
- The `text_to_speech` tool produces an `.ogg` (Opus) voice-compatible file;
  on Telegram it sends as a voice bubble. If Avi "doesn't hear anything,"
  the file may have been generated but never delivered — include the
  `MEDIA:/abs/path.ogg` line in the reply so it actually sends.

## Verify audio file is real (don't assume)

```bash
ffprobe -hide_banner /path/to/file.ogg   # Duration + "Audio: opus" = valid
```

A TTS call returning a file_path doesn't mean it was delivered to the chat.
Check the file is valid AND that a MEDIA: line went out with the reply.
