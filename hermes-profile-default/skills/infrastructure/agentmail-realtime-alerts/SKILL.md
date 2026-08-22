---
name: agentmail-realtime-alerts
description: "Configure AgentMail WS listener with stale-event watchdog."
version: 1.0.0
author: Alyosha
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [agentmail, email, agent-to-agent, real-time, websocket, watchdog, systemd, cron, alerts, configuration]
---

# AgentMail Real-time Alerts

This skill configures a systemd service on the VPS to monitor the AgentMail coordination inbox (`coordination@agentmail.to`) for new messages. It provides real-time alerts to Telegram via a WebSocket connection, with a cron poll as a fallback.

## Overview

- **Primary Alerting:** WebSocket listener connects outbound to AgentMail, pushing new mail events to Telegram instantly.
- **Fallback Alerting:** A 5-minute cron job polls the inbox; it alerts only for messages not seen by the WebSocket listener, preventing duplicate notifications.
- **Robustness:** The WebSocket listener includes a stale-event watchdog (configurable timeout via `AGENTMAIL_WS_STALE` env var, default 120s) that restarts the listener if no events are received, ensuring continuous monitoring.
- **Configuration:** Managed via `~/.hermes/.env` for API keys and `~/.hermes/profiles/alyosha/scripts/.agentmail_last_seen` for state.
- **Systemd Service:** Runs `agentmail-ws.service` for reliable background operation and auto-restart.

## Setup Steps

### 1. Install AgentMail SDK (if not already present)
Ensure the AgentMail Python SDK is available in the Hermes venv:
```bash
/usr/local/lib/hermes-agent/venv/bin/pip install agentmail
```

### 2. Deploy Listener Script
Copy the `agentmail_ws_listener.py` script to `/root/.hermes/scripts/` on the VPS. This script contains the WebSocket logic and watchdog.

### 3. Configure Environment Variables
Ensure `AGENTMAIL_API_KEY` and `TELEGRAM_BOT_TOKEN` are set in `~/.hermes/.env`.

### 4. Deploy Systemd Service
Create the `agentmail-ws.service` unit file at `/etc/systemd/system/agentmail-ws.service`:

```ini
[Unit]
Description=AgentMail WebSocket listener (coordination inbox -> Telegram)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/lib/hermes-agent/venv/bin/python3 -u /root/.hermes/scripts/agentmail_ws_listener.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 5. Enable and Start Service
```bash
systemctl daemon-reload
systemctl enable agentmail-ws
systemctl start agentmail-ws
```

### 6. Verify Operation
- `systemctl is-active agentmail-ws` → `active`
- `journalctl -u agentmail-ws --since "1 min ago"` → look for `subscribed to coordination@agentmail.to`
- Send a test email to `coordination@agentmail.to` and confirm the instant Telegram ping.

## Watchdog Mechanism

Background thread checks for inactivity every 15s. If no WS event for `STALE_TIMEOUT` seconds (default 120), the process exits (os._exit) and systemd restarts it. Catches server-side subscription drops where TCP stays alive but events stop.

Test procedure: set `AGENTMAIL_WS_STALE=25` via a temporary `Environment=` line in the unit, restart, confirm a STALE exit + systemd restart in journal, then remove the override.

## Fallback Mechanism

The 5-minute cron poll (`check_agentmail.py`, cron job "AgentMail coordination watchdog", no_agent) shares `.agentmail_last_seen` with the listener. Listener updates state after each alert; poll alerts only on messages newer than state. Do NOT sync state on WS connect (that suppresses gap messages — the poll must catch them).

## Security Considerations

- Outbound connection only — no inbound ports opened on the VPS.
- `AGENTMAIL_API_KEY` and `TELEGRAM_BOT_TOKEN` live in `~/.hermes/.env` (not world-readable).
- Future: scoped per-inbox/role API keys per AgentMail permissions docs (read-only monitor + read/send, spam/blocked hidden) when the lane goes production.

## Pitfalls

- The `agentmail` SDK must run from the Hermes venv (`/usr/local/lib/hermes-agent/venv/bin/python3`) — /usr/bin/python3 lacks it.
- Use `-u` for unbuffered stdout so journald shows live logs.
- The lifecycle guard can trip on heredoc python or `.py` file args in terminal; use execute_code for SDK introspection.
- Skill descriptions must fit 60 chars or creation is rejected.
