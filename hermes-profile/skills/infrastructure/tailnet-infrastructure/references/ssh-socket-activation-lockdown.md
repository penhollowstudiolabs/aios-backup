# Locking public SSH to tailnet-only: systemd socket activation recipe (Ubuntu/Debian)

Validated 2026-08-05 on both `aios` and `ilocos` (Ubuntu, Tailscale tailnet).

## Why sshd_config ListenAddress alone appears to "not work"
On modern Ubuntu/Debian, sshd runs under **systemd socket activation**:
- `ssh.socket` owns the TCP bind; `systemctl status ssh.socket` shows `Listen: 0.0.0.0:22 / [::]:22`.
- A systemd **generator** (`sshd-socket-generator`) reads `ListenAddress` from `sshd_config` and emits a derived bind into `/run/systemd/generator/ssh.socket.d/addresses.conf`.
- Because systemd owns the socket, editing `sshd_config` `ListenAddress` does NOT by itself rebind the live listener — the generator must re-run and `ssh.socket` must be restarted.
- `sshd -T` (effective config) will happily show the new `ListenAddress` even while the RUNNING socket is still on `0.0.0.0` — this mismatch is the trap.

## Correct sequence
1. Get the node's tailnet addresses:
   `tailscale ip -4` and `tailscale ip -6`
2. Write a drop-in that drives the generator:
   `printf 'ListenAddress <TAILNET_V4>\nListenAddress <TAILNET_V6>\n' > /etc/ssh/sshd_config.d/99-tailnet-listen.conf`
3. Validate: `sshd -t && sshd -T | grep -i listenaddress` (should show only the tailnet addrs)
4. Regenerate + rebind:
   `systemctl daemon-reload && systemctl restart ssh.socket`
5. Verify (see SKILL.md "Verify" section).

NOTE: on a box where you have local console/terminal, restarting the socket is safe (you can't lock yourself out of local access). When doing it over SSH to a peer, the running session usually survives (existing sshd children persist); if it drops, reconnect over the tailnet.

## Failure mode to avoid (and how to recover)
**Symptom:** `systemctl restart ssh.socket` → "Job failed"; journal shows:
`ssh.socket: Failed to create listening socket (100.x:22): Address already in use`
and `tailscale status` now shows NO `:22` listener at all → SSH fully down.

**Cause:** the socket got the SAME tailnet ListenStream twice — once from the generator's
`/run/systemd/generator/ssh.socket.d/addresses.conf` and once from a manual
`/etc/systemd/system/ssh.socket.d/*.conf` override you added. Duplicate bind = "Address already in use".

**Fix:** remove the manual `/etc/systemd/system/ssh.socket.d/` override (the generator already
derives the correct addresses from `sshd_config`), then `systemctl daemon-reload && systemctl restart ssh.socket`.
Result: single set of tailnet-only listeners.

**Rule:** pick ONE mechanism. The generator (driven by `sshd_config` `ListenAddress`) is the native one — do not also hand-write a socket override with the same addresses.

## Related gotchas
- `systemctl reload ssh` (SIGHUP) is NOT enough to rebind listeners — use `restart` after a config change.
- `tailscale status --json` / admin console can lag on renames; the human `tailscale status` view is authoritative for "did the rename stick."
- Before locking public SSH, confirm no cron/rsync targets the public IP, and that SSH clients (Hermes Desktop, scripts) already use tailnet names — you don't want to orphan the only remaining admin path.
