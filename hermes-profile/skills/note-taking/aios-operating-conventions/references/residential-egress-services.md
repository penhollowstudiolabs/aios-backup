# Datacenter-IP-blocked services — residential egress only

Avi's VPSes (aios, ilocos) are datacenter IPs. A growing set of consumer/retail
services refuse requests from cloud-provider IPs. This is a recurring class of
failure, not a one-off — expect it for any new consumer-platform integration.

## Known-blocked (verified)

| Service | Symptom | Workaround used |
|---|---|---|
| Amazon / retail | research blocks, listing tooling | residential egress (Avi's note: "Amazon/retail block VPS datacenter IPs; use residential egress for research") |
| YouTube transcript API | `youtube-transcript-api` returns "YouTube is blocking requests from your IP … IP belonging to a cloud provider" | **Hollow on the laptop** (residential IP) fetches the transcript and drops it in the AgentMail lane / vault; or a residential proxy if one exists. Never promise direct VPS fetching. |

## YouTube transcript setup (installed 8/10)

- Package: `youtube-transcript-api`, installed in the Hermes venv
  (`/usr/local/lib/hermes-agent/venv/bin/pip install youtube-transcript-api`).
- Skill: `youtube-content` (`media/`) — helper script
  `fetch_transcript.py URL --text-only | --timestamps | --language`.
- **Pitfall:** running via `uv run python3 <script>` creates a FRESH uv env
  without the package. Run the helper with the venv interpreter:
  `/usr/local/lib/hermes-agent/venv/bin/python3 <script>`.
- Terminal guard bug (8/10): inline `python3 -c` / `./venv/bin/...` command shapes
  can trip the cron lifecycle guard's "embedded null byte" error. Workaround:
  run the fetch via `execute_code` + `subprocess.run([venv_python, script, url])`.

## Decision rule for Avi

Do NOT burn money/infra on proxying from the VPS when the laptop already has a
residential IP and Hollow lives there. Default division: Hollow fetches, Alyosha
processes into summaries/chapters/blog. Match this to the existing
"one working lead per task / Hollow = laptop-local evidence" convention.
